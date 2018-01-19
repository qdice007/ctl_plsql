-- 添加测试数据

-- 增加任务配置(TEST)
INSERT INTO ctl.ctl_task_conf_tbl 
VALUES 
    ( 'TEST'
     ,'测试用'
     ,'SELECT COUNT(1) FROM ctl.ctl_holiday_conf_tbl WHERE task_name=''TEST'' AND holiday=:v_1'
     ,10
     ,'20161201'
     ,'20161202'
     ,'20161201'
     ,'20991231'
     ,'0'
     ,'0'
     ,'1'
    ) ;

-- 增加作业配置(属于TEST任务)
INSERT INTO ctl.ctl_jobs_conf_tbl 
VALUES 
    ( 'TEST'
     ,'源系统名_存储过程名_目标表名'
     ,'PROCEDURE'
     ,'作业程序执行内容'
     ,'NONE'
     ,'NONE'
     ,0
     ,'1'
     ,'作业描述'
    ) ;

-- 增加源文件配置(属于TEST任务)
INSERT INTO ctl.ctl_sfile_info_tbl 
VALUES 
    ( 'TEST'
     ,'SBS'
     ,'ACTCUS'
     ,'SBS_DIR'
     ,'客户普通信息表'
     ,'1'
    ) ;

-- 增加假日配置(属于TEST任务)
INSERT INTO ctl.ctl_holiday_conf_tbl 
VALUES 
    ( 'TEST'
     ,'20170531'
     ,'NONE'
     ,'1'
     ,SYSDATE 
    ) ;

COMMIT ;

-- END