-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

drop table if exists tweets;
drop table if exists mentions;
drop table if exists mentioned;

--------------------------------------------------------------------------------
-- tweets
--------------------------------------------------------------------------------
create external table tweets(key string,
    c_lng float, c_lat float,
    date_time string,
    year int, month tinyint, day tinyint, week int,
    hour tinyint, minute tinyint, second tinyint,
    hashtags_str string,
    user_mentions_str string,
    favorite_count int,
    filter_level string,
    g_lat float, g_lng float,
    id bigint, id_str string,
    in_reply_to_screen_name string,
    in_reply_to_status_id bigint, in_reply_to_status_id_str string,
    in_reply_to_user_id bigint, in_reply_to_user_id_str string,
    lang string,
    bb_lng float, bb_lat float,
    possibly_sensitive boolean,
    retweet_count int,
    source string,
    text string,
    truncated boolean,
    followers_count int,
    user_id bigint, user_id_str string,
    screen_name string)
stored by 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
with serdeproperties('hbase.columns.mapping'=
    ':key,t:c_lng,t:c_lat,t:date_time,t:year,t:month,t:day,t:week,t:hour,t:minute,t:second,e:hashtags_str,e:user_mentions_str,t:favorite_count,t:filter_level,t:g_lat,t:g_lng,t:id,t:id_str,t:in_reply_to_screen_name,t:in_reply_to_status_id,t:in_reply_to_status_id_str,t:in_reply_to_user_id,t:in_reply_to_user_id_str,t:lang,p:bb_lng,p:bb_lat,t:possibly_sensitive,t:retweet_count,t:source,t:text,t:truncated,u:followers_count,u:user_id,u:user_id_str,u:screen_name')
tblproperties('hbase.table.name'='tweets');

--------------------------------------------------------------------------------
-- mentions
--------------------------------------------------------------------------------
create external table mentions(key string,
    user_id bigint, screen_name string,
    r_user_id bigint, r_screen_name string)
stored by 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
with serdeproperties('hbase.columns.mapping'=
    ':key,f:user_id,f:screen_name,f:r_user_id,f:r_screen_name')
tblproperties('hbase.table.name'='mentions');

--------------------------------------------------------------------------------
-- mentioned
--------------------------------------------------------------------------------
create external table mentioned(key string,
    r_user_id bigint, r_screen_name string,
    user_id bigint, screen_name string)
stored by 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
with serdeproperties('hbase.columns.mapping'=
    ':key,f:r_user_id,f:r_screen_name,f:user_id,f:screen_name')
tblproperties('hbase.table.name'='mentioned');

--------------------------------------------------------------------------------
show tables;
