--_EVENTS_
-- Missed nodes yesterday
select e.scheduled_start as Schedule_start, n.tcp_name as Server, e.status as Last_schedule_name, n.domain_name as SLA, days(current_date) - days(n.lastacc_time) as Last_Access, a.schedule_name as Schedule_Name from events as e, nodes as n, associations as a where e.status='Missed' and e.node_name=n.node_name and e.node_name=a.node_name and days(current_timestamp)-days(e.scheduled_start)=1 order by scheduled_start desc

-- _SUMMARY_
-- Backup STG history
select entity as "Backup stg", mediaw as "MediaW", bytes/1024/1024/1024 as "GB", timestampdiff(4, end_time - start_time) as "Duration(Minutes)", start_time, end_time from summary_extended where activity = 'STGPOOL BACKUP' order by end_time desc
-- Sum of minutes a tape dirve have been workingj
select sum(timestampdiff(4, end_time - start_time)) as SUM_MIN, drive_name from summary_extended where activity = 'TAPE MOUNT' and start_time>'2016-05-07 00:00:01' and end_time<'2016-05-07 23:59:59' group by drive_name
-- When? How long? Whitch tape and in which dirve? Times can be adjusted as needed
select start_time, end_time, timestampdiff(4, end_time - start_time) as minutes, varchar(volume_name, 15) as volume, varchar(drive_name,30) as drive from summary_extended where start_time>'2016-05-07 00:00:01' and end_time<'2016-05-07 23:59:59' and activity = 'TAPE MOUNT' order by end_time
-- Let's look at restores # TODO: Figure out how to count all the mounts for all the processes
select date(a.end_time) as date, varchar(a.entity, 70) as server, timestampdiff(4, a.end_time-a.start_time) as minutes, a.bytes/1024/1024/1024 as GIB, round(decimal(a.bytes/1024/1024)/timestampdiff(2, a.end_time - a.start_time), 2) as MiB_S, count(b.msgno) from summary_extended a, actlog b where activity = 'RESTORE' and a.number = b.session and b.msgno in (8337, 8340) group by entity, bytes, end_time, start_time,number order by end_time
-- Check dedup and compression savings:
SELECT DATE(s.START_TIME) AS Date, (CAST(FLOAT(SUM(s.bytes_protected))/1024/1024 AS DECIMAL(12,2))) AS PROTECTED_MB, (CAST(FLOAT(SUM(s.bytes_written))/1024/1024 AS DECIMAL(12,2))) AS WRITTEN_MB, (CAST(FLOAT(SUM(s.dedup_savings))/1024/1024 AS DECIMAL(12,2))) AS DEDUPSAVINGS_MB, (CAST(FLOAT(SUM(s.comp_savings))/1024/1024 AS DECIMAL(12,2))) AS COMPSAVINGS_MB, (CAST(FLOAT(SUM(s.dedup_savings))/FLOAT(SUM(s.bytes_protected))*100 AS DECIMAL(5,2))) AS DEDUP_PCT, (CAST(FLOAT(SUM(s.bytes_protected) - SUM(s.bytes_written))/FLOAT(SUM(s.bytes_protected))*100 AS DECIMAL(5,2))) AS SAVINGS_PCT from summary s WHERE activity='BACKUP' or activity='ARCHIVE' GROUP BY DATE(S.START_TIME)



-- Time a volume has been mounted
select s.start_time, s.end_time, timestampdiff(4, s.end_time-s.start_time) as "Minutes tape mounted", s.drive_name, s.volume_name, v.stgpool_name, v.status, v.access, v.pct_utilized from summary as s, volumes as v where activity = 'TAPE MOUNT' and s.volume_name = v.volume_name order by end_time desc

--_VOLUMES_
-- Number of volumes in stgpool $1 where % reclaimable space is over $2
select count(volume_name) from volumes where stgpool_name = upper('$1') and pct_reclaim>$2

-- List volumes i stgpool $1 where % Reclaimable space is over $2
select volume_name, pct_reclaim from volumes where stgpool_name = upper('$1') and pct_reclaim>$2 order by 2 desc

-- Number of volumes per status and stgpool
select varchar(stgpool_name, 10) AS Stgpool, varchar(status, 10) AS Status, count(status) AS NumVols from volumes group by status, stgpool_name order by 1,3 desc

-- Sum number of volues per pct_reclaim grouped by tens
select count(volume_name) as numvols, cast(pct_reclaim as INT)/10*10 as PCT from volumes where stgpool_name = upper('copypool') group by cast(pct_reclaim as int)/10*10

--_BACKUPS_
-- Number of restorepoints in TSM4VE (BETA)
select substr(filespace_name,9) AS VM, count(ll_name) AS NumRestorePoints from backups where node_name = 'VCENTER_NODE' and ll_name like 'SNAPSHOT%' group by filespace_name order by 2 asc

--_ACTLOG_
-- Number of deleted and created volumes in a stgpool called FILEPOOL
select date(date_time) as date, 'ANR'||msgno||'I' as ANR, count(msgno) as num_vols from actlog where msgno in (1340, 1341) and message like '%FILEPOOL%' group by date(date_time), msgno
