#sql_list.py
import os 
PASS_F='p'
FAIL_F='f'
BLOCK_F='b'
BUILD_ID='180'
PLAN_NAME=''

PLAN_ID="select plan.id from `builds` build, `testplans` plan where build.`testplan_id` = plan.`id` and build.`name` = 'Full_Test_WW10'"

SUITE_LIST="select name,id,parent_id, node_type,node_order from testlink.nodes_hierarchy where id in (select distinct suite_id from executions_nodes where plan_id = ("+PLAN_ID+"))"

TEST_SQL="SELECT hw.`machine_name, \
	ts.`test_date`, \
	ts.`case_name`,\
	ts.`test_result`,\
	ts.`suite_name`,\
	ts.`start_time` \
	FROM `test_results` ts, \
	`hardware_configs` hw \
	WHERE ts.`test_date` = '2013-3-9' and  \
	hw.`hardware_config_index` = ts.`hardware_config_index` and \
	ts.`hardware_config_index` = '59'  \
	ORDER BY ts.`start_time` desc;"

NIGHTLY_SQL="SELECT hw.`machine_name`, \
	ts.`test_date`, \
	ts.`case_name`,\
	ts.`test_result`, \
	ts.`suite_name`, \
	ts.`start_time`\
	FROM `test_results` ts,\
	`hardware_configs` hw \
	WHERE ts.`test_date` = '2013-3-9' AND \
	hw.`hardware_config_index` = ts.`hardware_config_index` AND \
	ts.`hardware_config_index` = '59' \
	ORDER BY ts.`start_time` desc;"

TESTLINK_PASS_SQL="SELECT tc.`id`, \
	exe.`testplan_id`, \
	tc.`summary`,\
	tc.`status`,\
	exe.`status` \
	FROM `tcversions` tc, \
	`executions` exe, \
	`builds` build \
	WHERE tc.id = exe.id AND \
	exe.`status` = '" +PASS_F +"' AND  \
	build.`id` = '" +BUILD_ID+"' \
	ORDER BY tc.`id` asc;"

TESTLINK_FAIL_SQL="SELECT tc.`id`, \
	exe.`testplan_id`, \
	tc.`summary`,\
	tc.`status`,\
	exe.`status` \
	FROM `tcversions` tc, \
	`executions` exe ,\
	`builds` build \
	WHERE tc.id = exe.id AND \
	exe.`status` = '" +FAIL_F +"' AND\
	build.`id` = '" +BUILD_ID+"' \
	ORDER BY tc.`id` asc;"

TESTLINK_BLOCK_SQL="SELECT tc.`id`, \
	exe.`testplan_id`, \
	tc.`summary`,\
	tc.`status`,\
	exe.`status` \
	FROM `tcversions` tc, \
	`executions` exe ,\
	`builds` build \
	WHERE tc.id = exe.id AND \
	exe.`status` = '" +BLOCK_F +"' AND\
	build.`id` = '" +BUILD_ID+"' \
	ORDER BY tc.`id` asc;"


TESTLINK_RESULT_SQL="SELECT tresult.`execution_ts` as test_time, \
	tplan.`name` as plan_name, \
	tcase.`name` as case_name, \
	tresult.`status` as result,\
	tresult.`id` as execution_id,\
	tcase.`id` as case_id \
	FROM \
	`executions` tresult, \
	`nodes_hierarchy` tplan,\
	`nodes_hierarchy` tmp_case,\
	`nodes_hierarchy` tcase\
	WHERE\
	(tresult.`testplan_id` = tplan.`id`)\
	AND (\
	tresult.`tcversion_id` = tmp_case.`id` \
	AND\
	tmp_case.`parent_id` = tcase.`id`\
	AND\
	tcase.`name` != '')"

TESTLINK_RESULT_SQL_BAK="select tc.`tc_external_id`, \
	tc.`summary`,\
	exe.`testplan_id`,\
	exe.`status` \
	from `executions` exe, \
	`tcversions` tc \
	where exe.`tcversion_id` = tc.`id` and \
	exe.`testplan_id` =7949  and \
	tc.`summary` != '' \
	order by exe.`execution_ts` asc"

TESTLINK_RESULT1_SQL="SELECT tc.`tc_external_id`, \
	tc.`summary`,\
	exe.`status`, \
	pro.`prefix` \
	FROM `tcversions` tc, \
	`executions` exe ,\
	`builds` build ,\
	`testprojects` pro \
	WHERE tc.`id` = exe.`id` AND \
	build.`id` = '" +BUILD_ID+"' \
	ORDER BY tc.`execution_ts` asc; "


TESTLINK_RESULTS_SQL="SELECT tc.`tc_external_id`, \
	tc.`summary`,\
	tc.`status`,\
	exe.`status`, \
	pro.`prefix`, \
	bug.`bug_id` \
	FROM `tcversions` tc, \
	`executions` exe ,\
	`execution_bugs` bug ,\
	`builds` build ,\
	`testprojects` pro \
	WHERE tc.`id` = exe.`id` AND \
	build.`id` = '" +BUILD_ID+"' \
	ORDER BY tc.`id` asc; "

TEST_SQL="SELECT T2.id, T2.name \
 	FROM (  \
	SELECT  \
	@r AS _id,\
	(SELECT @r := parent_id FROM table1 WHERE id = _id) AS parent_id, \
	@l := @l + 1 AS lvl  \
	FROM  \
	(SELECT @r := 5, @l := 0) vars,  \
	table1 h \
	WHERE @r <> 0) T1  \
	JOIN table1 T2  \
	ON T1._id = T2.id  \
	ORDER BY T1.lvl DESC  "
