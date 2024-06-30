--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- Name: employee_detect_cycle(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.employee_detect_cycle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.manager_id IS NOT NULL AND EXISTS (
    WITH RECURSIVE list_managers (parent) AS (
     SELECT s.manager_id
     FROM employee AS s
     WHERE s.id = NEW.manager_id
    UNION
     SELECT s.manager_id
     FROM employee AS s
     INNER JOIN list_managers lr ON lr.parent = s.id
    )
    SELECT * FROM list_managers WHERE list_managers.parent = NEW.id LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Invalid cycle detected in manager/managed relationship in employees';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;


ALTER FUNCTION public.employee_detect_cycle() OWNER TO root;

--
-- Name: employee_update_manager_path(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.employee_update_manager_path() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  new_manager_path ltree;
BEGIN
  IF NEW.manager_id IS NULL THEN
    NEW.manager_path = NEW.id::text::ltree;
  ELSIF TG_OP = 'INSERT' OR OLD.manager_id IS NULL OR OLD.manager_id != NEW.manager_id THEN
    SELECT manager_path FROM employee WHERE id = NEW.manager_id INTO new_manager_path;
    IF new_manager_path IS NULL THEN
      RAISE EXCEPTION 'Invalid manager_id %', NEW.manager_id;
    END IF;
    NEW.manager_path = new_manager_path || NEW.id::text::ltree;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.employee_update_manager_path() OWNER TO root;

--
-- Name: employee_update_manager_path_of_managed(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.employee_update_manager_path_of_managed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE employee SET manager_path = NEW.manager_path || id::text::ltree WHERE manager_id = NEW.id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.employee_update_manager_path_of_managed() OWNER TO root;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.employee (
    id integer NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    manager_id integer,
    manager_path public.ltree NOT NULL
);


ALTER TABLE public.employee OWNER TO root;

--
-- Name: employee_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_id_seq OWNER TO root;

--
-- Name: employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.employee_id_seq OWNED BY public.employee.id;


--
-- Name: employee id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.employee ALTER COLUMN id SET DEFAULT nextval('public.employee_id_seq'::regclass);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- Name: employee_manager_id_idx; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX employee_manager_id_idx ON public.employee USING btree (manager_id);


--
-- Name: employee_manager_path_idx; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX employee_manager_path_idx ON public.employee USING gist (manager_path);


--
-- Name: employee tgr_employee_detect_cycle; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER tgr_employee_detect_cycle AFTER INSERT OR UPDATE ON public.employee FOR EACH ROW EXECUTE FUNCTION public.employee_detect_cycle();


--
-- Name: employee tgr_employee_update_manager_path; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER tgr_employee_update_manager_path BEFORE INSERT OR UPDATE ON public.employee FOR EACH ROW EXECUTE FUNCTION public.employee_update_manager_path();


--
-- Name: employee tgr_employee_update_manager_path_of_managed; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER tgr_employee_update_manager_path_of_managed AFTER UPDATE ON public.employee FOR EACH ROW WHEN ((new.manager_path IS DISTINCT FROM old.manager_path)) EXECUTE FUNCTION public.employee_update_manager_path_of_managed();


--
-- Name: employee employee_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employee(id) ON UPDATE SET NULL ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

