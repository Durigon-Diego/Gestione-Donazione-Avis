-- Schema version 1.0.0
------------
-- Tables --
------------
--
-- Name: app_versions; Type: TABLE DROP; Schema: public; Owner: -
DROP TABLE IF EXISTS public.app_versions CASCADE;

-- Name: app_versions; Type: TABLE; Schema: public; Owner: -
CREATE TABLE public.app_versions (
    id uuid DEFAULT gen_random_uuid(),
    version text NOT NULL,
    required boolean NOT NULL DEFAULT false,
    notes text,
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now())
);

-- Name: app_versions app_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.app_versions
ADD
    CONSTRAINT app_versions_pkey PRIMARY KEY (id);

-- Name: app_versions app_versions_version_key; Type: CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.app_versions
ADD
    CONSTRAINT app_versions_version_key UNIQUE (version);

-- Name: app_versions; Type: RealTime; Schema: public; Owner: -
ALTER PUBLICATION supabase_realtime
ADD
    TABLE ONLY public.app_versions;

--
-- Name: operators; Type: TABLE DROP; Schema: public; Owner: -
DROP TABLE IF EXISTS public.operators CASCADE;

-- Name: operators; Type: TABLE; Schema: public; Owner: -
CREATE TABLE public.operators (
    id uuid NOT NULL,
    name text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    is_admin boolean DEFAULT false NOT NULL
);

-- Name: operators operators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.operators
ADD
    CONSTRAINT operators_pkey PRIMARY KEY (id);

-- Name: operators operators_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.operators
ADD
    CONSTRAINT operators_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Name: operators; Type: RealTime; Schema: public; Owner: -
ALTER PUBLICATION supabase_realtime
ADD
    TABLE ONLY public.operators;

--
-- Name: donation_days; Type: TABLE DROP; Schema: public; Owner: -
DROP TABLE IF EXISTS public.donation_days CASCADE;

-- Name: donation_days; Type: TABLE; Schema: public; Owner: -
CREATE TABLE public.donation_days (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date NOT NULL,
    notes text
);

-- Name: donation_days donation_days_pkey; Type: CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.donation_days
ADD
    CONSTRAINT donation_days_pkey PRIMARY KEY (id);

-- Name: donation_days donation_days_date_key; Type: CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.donation_days
ADD
    CONSTRAINT donation_days_date_key UNIQUE (date);

--
-- Name: donors; Type: TABLE DROP; Schema: public; Owner: -
DROP TABLE IF EXISTS public.donors CASCADE;

-- Name: donors; Type: TABLE; Schema: public; Owner: -
CREATE TABLE public.donors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    birth_date date NOT NULL,
    scheduled_for uuid,
    scheduled_time_slot text NOT NULL,
    folder_number integer,
    current_status text DEFAULT 'scheduled' :: text,
    operator_checkin_id uuid,
    checkin_timestamp timestamp without time zone,
    operator_screening_id uuid,
    screening_timestamp timestamp without time zone,
    screening_result text,
    operator_exam_id uuid,
    exam_timestamp timestamp without time zone,
    exam_result text,
    operator_donation_id uuid,
    donation_timestamp timestamp without time zone,
    CONSTRAINT donors_current_status_check CHECK (
        (
            current_status = ANY (
                ARRAY ['scheduled'::text, 'arrived'::text, 'accepted'::text, 'rejected_at_checkin'::text, 'waiting_for_exam'::text, 'unfit'::text, 'fit'::text, 'donated'::text]
            )
        )
    )
);

-- Name: donors donors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.donors
ADD
    CONSTRAINT donors_pkey PRIMARY KEY (id);

-- Name: donors donors_scheduled_for_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.donors
ADD
    CONSTRAINT donors_scheduled_for_fkey FOREIGN KEY (scheduled_for) REFERENCES public.donation_days(id) ON DELETE CASCADE;

-- Name: donors donors_operator_checkin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.donors
ADD
    CONSTRAINT donors_operator_checkin_id_fkey FOREIGN KEY (operator_checkin_id) REFERENCES public.operators(id);

-- Name: donors donors_operator_screening_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.donors
ADD
    CONSTRAINT donors_operator_screening_id_fkey FOREIGN KEY (operator_screening_id) REFERENCES public.operators(id);

-- Name: donors donors_operator_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.donors
ADD
    CONSTRAINT donors_operator_exam_id_fkey FOREIGN KEY (operator_exam_id) REFERENCES public.operators(id);

-- Name: donors donors_operator_donation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
ALTER TABLE
    ONLY public.donors
ADD
    CONSTRAINT donors_operator_donation_id_fkey FOREIGN KEY (operator_donation_id) REFERENCES public.operators(id);

---------------
-- Functions --
---------------
-- Name: get_latest_app_version(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.get_latest_app_version;

-- Name: get_latest_app_version(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.get_latest_app_version() RETURNS TABLE (
    version text,
    required boolean,
    notes text
) LANGUAGE sql AS $ $
SELECT
    version,
    required,
    notes
FROM
    public.app_versions
ORDER BY
    created_at DESC
LIMIT
    1 $ $;

-- Name: get_my_operator_profile(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.get_my_operator_profile;

-- Name: get_my_operator_profile(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.get_my_operator_profile() RETURNS TABLE(
    id uuid,
    name text,
    is_admin boolean,
    active boolean
) LANGUAGE sql SECURITY DEFINER AS $ $
select
    id,
    name,
    is_admin,
    active
from
    operators
where
    id = auth.uid();

$ $;

-- Name: is_admin_user(); Type: FUNCTION DROP; Schema: public; Owner: -
DROP FUNCTION IF EXISTS public.is_admin_user;

-- Name: is_admin_user(); Type: FUNCTION; Schema: public; Owner: -
CREATE FUNCTION public.is_admin_user() RETURNS boolean LANGUAGE sql STABLE AS $ $
select
    exists (
        select
            1
        from
            public.operators
        where
            id = auth.uid()
            and is_admin = true
    );

$ $;

-------------------------------------
-- Row Level Security and Policies --
-------------------------------------
-- Name: app_versions; Type: ROW SECURITY; Schema: public; Owner: -
ALTER TABLE
    public.app_versions ENABLE ROW LEVEL SECURITY;

-- Name: app_versions Everyone can select app versions; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Everyone can select app versions" ON public.app_versions FOR
SELECT
    USING (true);

--
-- Name: operators; Type: ROW SECURITY; Schema: public; Owner: -
ALTER TABLE
    public.operators ENABLE ROW LEVEL SECURITY;

-- Name: operators Admin can insert operators; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Admin can insert operators" ON public.operators FOR
INSERT
    WITH CHECK (public.is_admin_user());

-- Name: operators Admin can read all operators, operators can read own data; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Admin can read all operators, operators can read own data" ON public.operators FOR
SELECT
    USING (
        (
            (id = auth.uid())
            OR public.is_admin_user()
        )
    );

-- Name: operators Admin can update operators; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Admin can update operators" ON public.operators FOR
UPDATE
    USING (public.is_admin_user()) WITH CHECK (public.is_admin_user());

--
-- Name: donation_days; Type: ROW SECURITY; Schema: public; Owner: -
ALTER TABLE
    public.donation_days ENABLE ROW LEVEL SECURITY;

-- Name: donation_days Authenticated users full access; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated users full access" ON public.donation_days AS RESTRICTIVE USING ((auth.role() = 'authenticated' :: text)) WITH CHECK ((auth.role() = 'authenticated' :: text));

--
-- Name: donors; Type: ROW SECURITY; Schema: public; Owner: -
ALTER TABLE
    public.donors ENABLE ROW LEVEL SECURITY;

-- Name: donors Authenticated users can delete donors; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated users can delete donors" ON public.donors FOR DELETE TO authenticated USING ((auth.uid() IS NOT NULL));

-- Name: donors Authenticated users can insert donors; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated users can insert donors" ON public.donors FOR
INSERT
    TO authenticated WITH CHECK ((auth.uid() IS NOT NULL));

-- Name: donors Authenticated users can select donors; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated users can select donors" ON public.donors FOR
SELECT
    TO authenticated USING ((auth.uid() IS NOT NULL));

-- Name: donors Authenticated users can update donors; Type: POLICY; Schema: public; Owner: -
CREATE POLICY "Authenticated users can update donors" ON public.donors FOR
UPDATE
    TO authenticated USING ((auth.uid() IS NOT NULL)) WITH CHECK ((auth.uid() IS NOT NULL));