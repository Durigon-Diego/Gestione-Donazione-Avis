-- Schema version 1.0.0
------------
-- Tables --
------------

-- app_versions --
-- Name: app_versions; Type: TABLE DROP; Schema: public; Owner: -
DROP TABLE IF EXISTS public.app_versions CASCADE;

-- Name: app_versions; Type: TABLE; Schema: public; Owner: -
CREATE TABLE public.app_versions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    version text UNIQUE NOT NULL,
    required boolean NOT NULL DEFAULT FALSE,
    notes text,
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now())
);

-- Name: app_versions; Type: RealTime; Schema: public; Owner: -
ALTER PUBLICATION supabase_realtime ADD
TABLE ONLY public.app_versions;

-- operators --
-- Name: operators; Type: TABLE DROP; Schema: public; Owner: -
DROP TABLE IF EXISTS public.operators CASCADE;

-- Name: operators; Type: TABLE; Schema: public; Owner: -
CREATE TABLE public.operators (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    auth_user_id uuid UNIQUE REFERENCES auth.users (id) ON DELETE SET NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    nickname text,
    active boolean NOT NULL DEFAULT TRUE,
    is_admin boolean NOT NULL DEFAULT FALSE,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by uuid REFERENCES public.operators (id) ON DELETE SET NULL,
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_by uuid REFERENCES public.operators (id) ON DELETE SET NULL,
    deleted_at timestamp with time zone DEFAULT NULL,
    deleted_by uuid REFERENCES public.operators (id) ON DELETE SET NULL,
    CONSTRAINT operators_name_unique UNIQUE (first_name, last_name, nickname)
);

-- Name: operators; Type: RealTime; Schema: public; Owner: -
ALTER PUBLICATION supabase_realtime ADD
TABLE ONLY public.operators;

-- donation_days --
-- Name: donation_days; Type: TABLE DROP; Schema: public; Owner: -
DROP TABLE IF EXISTS public.donation_days CASCADE;

-- Name: donation_days; Type: TABLE; Schema: public; Owner: -
CREATE TABLE public.donation_days (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    date date UNIQUE NOT NULL,
    notes text
);

-- donors --
-- Name: donors; Type: TABLE DROP; Schema: public; Owner: -
DROP TABLE IF EXISTS public.donors CASCADE;

-- Name: donors; Type: TABLE; Schema: public; Owner: -
CREATE TABLE public.donors (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    birth_date date NOT NULL,
    scheduled_for uuid REFERENCES public.donation_days (id) ON DELETE CASCADE,
    scheduled_time_slot text NOT NULL,
    folder_number integer,
    current_status text DEFAULT 'scheduled'::text,
    operator_checkin_id uuid REFERENCES public.operators (id) ON DELETE SET NULL,
    checkin_timestamp timestamp without time zone,
    operator_screening_id uuid REFERENCES public.operators (id) ON DELETE SET NULL,
    screening_timestamp timestamp without time zone,
    screening_result text,
    operator_exam_id uuid REFERENCES public.operators (id) ON DELETE SET NULL,
    exam_timestamp timestamp without time zone,
    exam_result text,
    operator_donation_id uuid REFERENCES public.operators (id) ON DELETE SET NULL,
    donation_timestamp timestamp without time zone,

    CONSTRAINT donors_current_status_check CHECK (
        (
            current_status = any(
                ARRAY[
                    'scheduled'::text,
                    'arrived'::text,
                    'accepted'::text,
                    'rejected_at_checkin'::text,
                    'waiting_for_exam'::text,
                    'unfit'::text,
                    'fit'::text,
                    'donated'::text
                ]
            )
        )
    )
);

---------------
-- Functions --
---------------
-- Name: get_latest_app_version(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.get_latest_app_version;

-- Name: get_latest_app_version(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.get_latest_app_version()
RETURNS TABLE (
    version text,
    required boolean,
    notes text
)
LANGUAGE sql
SET search_path = ''
AS $$
    SELECT
        version,
        required,
        notes
    FROM
        public.app_versions
    ORDER BY
        created_at DESC
    LIMIT
        1;
$$;

-- Name: is_valid_user(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.is_valid_user;

-- Name: is_valid_user(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.is_valid_user() RETURNS boolean
LANGUAGE sql STABLE
SET search_path = ''
AS $$
    SELECT
        EXISTS (
            SELECT
                1
            FROM
                public.operators
            WHERE
                auth_user_id IS NOT NULL
                AND auth_user_id = (SELECT auth.uid())
        );
$$;

-- Name: is_active_user(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.is_active_user;

-- Name: is_active_user(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.is_active_user() RETURNS boolean
LANGUAGE sql STABLE
SET search_path = ''
AS $$
    SELECT
        EXISTS (
            SELECT
                1
            FROM
                public.operators
            WHERE
                auth_user_id IS NOT NULL
                AND auth_user_id = (SELECT auth.uid())
                AND active = TRUE
        );
$$;

-- Name: is_admin_user(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.is_admin_user;

-- Name: is_admin_user(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.is_admin_user() RETURNS boolean
LANGUAGE sql STABLE
SET search_path = ''
AS $$
    SELECT
        EXISTS (
            SELECT
                1
            FROM
                public.operators
            WHERE
                auth_user_id IS NOT NULL
                AND auth_user_id = (SELECT auth.uid())
                AND is_admin = TRUE
        );
$$;

-- Name: get_my_operator_id(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.get_my_operator_id;

-- Name: get_my_operator_id(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.get_my_operator_id()
RETURNS uuid
LANGUAGE sql STABLE
SET search_path = ''
AS $$
    SELECT
        id
    FROM
        public.operators
    WHERE
        auth_user_id IS NOT NULL
        AND auth_user_id = (SELECT auth.uid());
$$;

-- Name: get_my_operator_profile(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.get_my_operator_profile;

-- Name: get_my_operator_profile(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.get_my_operator_profile()
RETURNS TABLE (
    id uuid,
    auth_user_id uuid,
    first_name text,
    last_name text,
    nickname text,
    active boolean,
    is_admin boolean,
    created_at timestamp with time zone,
    created_by uuid,
    created_by_first_name text,
    created_by_last_name text,
    created_by_nickname text,
    updated_at timestamp with time zone,
    updated_by uuid,
    updated_by_first_name text,
    updated_by_last_name text,
    updated_by_nickname text,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    deleted_by_first_name text,
    deleted_by_last_name text,
    deleted_by_nickname text
)
LANGUAGE sql
SET search_path = ''
SECURITY DEFINER
AS $$
SELECT
    o.id,
    o.auth_user_id,
    o.first_name,
    o.last_name,
    o.nickname,
    o.active,
    o.is_admin,

    o.created_at,
    o.created_by,
    cb.first_name AS created_by_first_name,
    cb.last_name AS created_by_last_name,
    cb.nickname AS created_by_nickname,

    o.updated_at,
    o.updated_by,
    ub.first_name AS updated_by_first_name,
    ub.last_name AS updated_by_last_name,
    ub.nickname AS updated_by_nickname,

    o.deleted_at,
    o.deleted_by,
    db.first_name AS deleted_by_first_name,
    db.last_name AS deleted_by_last_name,
    db.nickname AS deleted_by_nickname
FROM
    public.operators o
LEFT JOIN public.operators AS cb ON o.created_by = cb.id
LEFT JOIN public.operators AS ub ON o.updated_by = ub.id
LEFT JOIN public.operators AS db ON o.deleted_by = db.id
WHERE
    o.auth_user_id IS NOT NULL
    AND o.auth_user_id = (SELECT auth.uid());
$$;

-- Name: get_operators_profiles(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.get_operators_profiles;

-- Name: get_operators_profiles(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.get_operators_profiles()
RETURNS TABLE (
    id uuid,
    auth_user_id uuid,
    first_name text,
    last_name text,
    nickname text,
    active boolean,
    is_admin boolean,
    created_at timestamp with time zone,
    created_by uuid,
    created_by_first_name text,
    created_by_last_name text,
    created_by_nickname text,
    updated_at timestamp with time zone,
    updated_by uuid,
    updated_by_first_name text,
    updated_by_last_name text,
    updated_by_nickname text,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    deleted_by_first_name text,
    deleted_by_last_name text,
    deleted_by_nickname text
)
LANGUAGE sql
SET search_path = ''
SECURITY DEFINER
AS $$
SELECT
    o.id,
    o.auth_user_id,
    o.first_name,
    o.last_name,
    o.nickname,
    o.active,
    o.is_admin,

    o.created_at,
    o.created_by,
    cb.first_name AS created_by_first_name,
    cb.last_name AS created_by_last_name,
    cb.nickname AS created_by_nickname,

    o.updated_at,
    o.updated_by,
    ub.first_name AS updated_by_first_name,
    ub.last_name AS updated_by_last_name,
    ub.nickname AS updated_by_nickname,

    o.deleted_at,
    o.deleted_by,
    db.first_name AS deleted_by_first_name,
    db.last_name AS deleted_by_last_name,
    db.nickname AS deleted_by_nickname
FROM
    public.operators AS o
LEFT JOIN public.operators AS cb ON o.created_by = cb.id
LEFT JOIN public.operators AS ub ON o.updated_by = ub.id
LEFT JOIN public.operators AS db ON o.deleted_by = db.id
WHERE
    public.is_admin_user();
$$;

--------------
-- Triggers --
--------------

-- Name: operators_audit(); Type: TRIGGER FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.operators_audit;

-- Name: operators_audit(); Type: TRIGGER FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.operators_audit()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
    DECLARE
        op_id uuid;
        ts timestamp with time zone := now();
    BEGIN
        SELECT public.get_my_operator_id() INTO op_id;

        IF (TG_OP = 'INSERT') THEN
            NEW.created_by := op_id;
            NEW.created_at := ts;
            NEW.updated_by := op_id;
            NEW.updated_at := ts;

        ELSIF (TG_OP = 'UPDATE') THEN
            NEW.updated_by := op_id;
            NEW.updated_at := ts;

            IF (
                NEW.auth_user_id IS DISTINCT FROM OLD.auth_user_id
                AND NEW.auth_user_id IS NULL
            ) THEN
                NEW.deleted_by := op_id;
                NEW.deleted_at := ts;
            END IF;
        END IF;

        RETURN NEW;
    END;
$$;

-- Name: trg_operators_audit; Type: TRIGGER DROP; Schema: public; Owner: -
DROP TRIGGER IF EXISTS trg_operators_audit ON public.operators;

-- Name: trg_operators_audit; Type: TRIGGER; Schema: public; Owner: -
CREATE TRIGGER trg_operators_audit
BEFORE INSERT OR UPDATE
ON public.operators
FOR EACH ROW
EXECUTE FUNCTION public.operators_audit();

-- Name: block_operators_delete(); Type: TRIGGER FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.block_operators_delete;

-- Name: block_operators_delete(); Type: TRIGGER FUNCTION; Schema: public; Owner: -
CREATE FUNCTION block_operators_delete()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
    BEGIN
        RAISE EXCEPTION 'Delete not allowed on operators';
    END;
$$;

-- Name: trg_block_operators_delete; Type: TRIGGER DROP; Schema: public; Owner: -
DROP TRIGGER IF EXISTS trg_block_operators_delete ON public.operators;

-- Name: trg_block_operators_delete; Type: TRIGGER; Schema: public; Owner: -
CREATE TRIGGER trg_block_operators_delete
BEFORE DELETE
ON public.operators
FOR EACH ROW
EXECUTE FUNCTION block_operators_delete();

-------------------------------------
-- Row Level Security and Policies --
-------------------------------------

-- app_versions --
-- Name: app_versions; Type: ROW SECURITY; Schema: public; Owner: -
ALTER TABLE public.app_versions ENABLE ROW LEVEL SECURITY;

-- Name: app_versions Everyone can select app versions; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Everyone_can_select_app_versions"
ON public.app_versions
FOR SELECT
USING (TRUE);

-- operators --
-- Name: operators; Type: ROW SECURITY; Schema: public; Owner: -
ALTER TABLE public.operators ENABLE ROW LEVEL SECURITY;

-- Name: operators Admin can insert operators; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Admin_can_insert_operators"
ON public.operators
FOR INSERT
WITH CHECK (
    public.is_admin_user()
    AND created_by IS NULL
    AND updated_by IS NULL
    AND deleted_by IS NULL
    AND created_at IS NULL
    AND updated_at IS NULL
    AND deleted_at IS NULL
);

-- Name: operators Admin can update operators; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Admin_can_update_operators"
ON public.operators
FOR UPDATE
USING (public.is_admin_user())
WITH CHECK (
    public.is_admin_user()
    AND created_by IS NOT DISTINCT FROM public.operators.created_by
    AND updated_by IS NOT DISTINCT FROM public.operators.updated_by
    AND deleted_by IS NOT DISTINCT FROM public.operators.deleted_by
    AND created_at IS NOT DISTINCT FROM public.operators.created_at
    AND updated_at IS NOT DISTINCT FROM public.operators.updated_at
    AND deleted_at IS NOT DISTINCT FROM public.operators.deleted_at
);

-- Name: operators Admin can read all operators, operators can read own data; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Admin_can_read_all_operators_and_operators_can_read_own_data"
ON public.operators
FOR SELECT
USING (
    (
        auth_user_id IS NOT NULL
        AND (auth_user_id = (SELECT auth.uid()))
    )
    OR public.is_admin_user()
);

-- - donation_days --
-- Name: donation_days; Type: ROW SECURITY; Schema: public; Owner: -
ALTER TABLE public.donation_days ENABLE ROW LEVEL SECURITY;

-- Name: donation_days Authenticated users full access; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated_users_full_access"
ON public.donation_days
AS RESTRICTIVE
USING ((SELECT auth.uid()) IS NOT NULL)
WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

-- donors --
-- Name: donors; Type: ROW SECURITY; Schema: public; Owner: -
ALTER TABLE public.donors ENABLE ROW LEVEL SECURITY;

-- Name: donors Authenticated users can delete donors; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated_users_can_delete_donors"
ON public.donors
FOR DELETE
TO authenticated
USING ((SELECT auth.uid()) IS NOT NULL);

-- Name: donors Authenticated users can insert donors; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated_users_can_insert_donors"
ON public.donors
FOR INSERT
TO authenticated
WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

-- Name: donors Authenticated users can select donors; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated_users_can_select_donors"
ON public.donors
FOR SELECT
TO authenticated
USING ((SELECT auth.uid()) IS NOT NULL);

-- Name: donors Authenticated users can update donors; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated_users_can_update_donors"
ON public.donors
FOR UPDATE
TO authenticated
USING ((SELECT auth.uid()) IS NOT NULL)
WITH CHECK ((SELECT auth.uid()) IS NOT NULL);
