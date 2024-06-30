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
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.employee (id, name, manager_id, manager_path) FROM stdin;
1	Alice	\N	1
2	Bob	1	1.2
3	Carol	1	1.3
4	David	2	1.2.4
5	Eve	4	1.2.4.5
6	Frank	2	1.2.6
\.


--
-- Name: employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.employee_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

