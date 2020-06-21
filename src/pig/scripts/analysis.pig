/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


register '/pig-libs/*.jar'
register '/pig-0.17.0/lib/*.jar'
register '/pig-0.17.0/lib/h2/*.jar'
register '/pig-0.17.0/ivy/*.jar'

register '/hbase-1.6.0/lib/*.jar'

register '/opt/hadoop-2.6.0/share/hadoop/common/*.jar'
register '/opt/hadoop-2.6.0/share/hadoop/common/lib/*.jar'
register '/opt/hadoop-2.6.0/share/hadoop/hdfs/*.jar'
register '/opt/hadoop-2.6.0/share/hadoop/hdfs/lib/*.jar'
register '/opt/hadoop-2.6.0/share/hadoop/mapreduce/*.jar'
register '/opt/hadoop-2.6.0/share/hadoop/tools/lib/*.jar'
register '/opt/hadoop-2.6.0/share/hadoop/yarn/*.jar'
register '/opt/hadoop-2.6.0/share/hadoop/yarn/lib/*.jar'


define UniformDate mutual.UniformDate();
define Related relationships.Related();
define Coordinates tweets.Coordinates();
define Hashtags tweets.Hashtags();
define UserMentions tweets.UserMentions();
define MD5gen util.MD5gen();

/*******************************************************************************
 * mutual
 ******************************************************************************/

mutual = load 'hdfs://namenode:9000/user/hduser/flume/twitter/*/*/*/*/*/*'
    using com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad=true') as (json:map[]);

mutual = foreach mutual generate 
    Coordinates($0#'coordinates') as c_coordinates:tuple(float, float),
    ToDate(UniformDate((chararray)$0#'created_at'), 'yyyyMMddHHmmssZ', '+01:00') as date_time:datetime,
    (bag{})$0#'entities'#'hashtags' as hashtags,
    (bag{})$0#'entities'#'user_mentions' as user_mentions,
    (int)$0#'favorite_count' as favorite_count,
    (chararray)$0#'filter_level' as filter_level,
    Coordinates($0#'geo') as g_coordinates:tuple(float, float),
    (long)$0#'id' as id,
    (chararray)$0#'id_str' as id_str,
    (chararray)$0#'in_reply_to_screen_name' as in_reply_to_screen_name,
    (long)$0#'in_reply_to_status_id' as in_reply_to_status_id,
    (chararray)$0#'in_reply_to_status_id_str' as in_reply_to_status_id_str,
    (long)$0#'in_reply_to_user_id' as in_reply_to_user_id,
    (chararray)$0#'in_reply_to_user_id_str' as in_reply_to_user_id_str,
    (chararray)$0#'lang' as lang,
    Coordinates($0#'place'#'bounding_box') as bb_coordinates:tuple(float, float),
    (boolean)$0#'possibly_sensitive' as possibly_sensitive,
    (int)$0#'retweet_count' as retweet_count,
    (chararray)$0#'source' as source,
    (chararray)$0#'text' as text,
    (boolean)$0#'truncated' as truncated,
    (int)$0#'user'#'followers_count' as followers_count,
    (long)$0#'user'#'id' as user_id,
    (chararray)$0#'user'#'id_str' as user_id_str,
    (chararray)$0#'user'#'screen_name' as screen_name;

/*******************************************************************************
 * tweets
 ******************************************************************************/

tweets = foreach mutual generate (chararray)MD5gen(id_str) as rowkey:chararray,
    c_coordinates.$0 as c_lng:float, c_coordinates.$1 as c_lat:float,
    date_time,
    GetYear(date_time) as year, GetMonth(date_time) as month, GetDay(date_time) as day, GetWeek(date_time) as week,
    GetHour(date_time) as hour, GetMinute(date_time) as minute, GetSecond(date_time) as second,
    Hashtags(hashtags) as hashtags_str:chararray,
    UserMentions(user_mentions) as user_mentions_str:chararray,
    favorite_count,
    filter_level,
    g_coordinates.$0 as g_lat:float, g_coordinates.$1 as g_lng:float,
    id, id_str,
    in_reply_to_screen_name,
    in_reply_to_status_id, in_reply_to_status_id_str,
    in_reply_to_user_id, in_reply_to_user_id_str,
    lang,
    bb_coordinates.$0 as bb_lng:float, bb_coordinates.$1 as bb_lat:float,
    possibly_sensitive,
    retweet_count,
    source,
    text,
    truncated,
    followers_count,
    user_id, user_id_str,
    screen_name;

tweets = filter tweets by
    hashtags_str matches '.*\\b(COVID|COVID-19|covid|covid-19|[Ss]alud|[Ee]nfermedad|[Cc]ovid|[Cc]ovid-19|[Mm][eé]dicos|[Ss]anitarios|[Mm]inisterio|[Dd]esescalada|[Pp]andemia|[Aa]plausos)\\b.*'
    or text matches '.*\\b(COVID|COVID-19|covid|covid-19|[Ss]alud|[Ee]nfermedad|[Cc]ovid|[Cc]ovid-19|[Mm][eé]dicos|[Ss]anitarios|[Mm]inisterio|[Dd]esescalada|[Pp]andemia|[Aa]plausos)\\b.*';


-- tweets = foreach tweets generate rowkey, hashtags_str, text;
-- dump tweets;
-- describe tweets;

-- select count(*) as coTweets from tweets;
-- grTweets = group tweets all;
-- coTweets = foreach grTweets generate COUNT(tweets);
-- dump coTweets;


/*******************************************************************************
 * relationships, mentions, mentioned
 ******************************************************************************/

-- (a, {(b,c), (d,e)})
-- If we apply the expression GENERATE $0, flatten($1) to this tuple,
-- we will create new tuples: (a, b, c) and (a, d, e)

relationships = foreach mutual generate 
    user_id, user_id_str, screen_name,
    flatten(Related(user_mentions)) as (r_user_id:long, r_user_id_str:chararray, r_screen_name:chararray);

relationships = filter relationships by r_user_id is not null;

mentions = foreach relationships generate CONCAT(MD5gen(user_id_str), MD5gen(r_user_id_str)) as rowkey:chararray,
    user_id, screen_name,
    r_user_id, r_screen_name;

mentioned = foreach relationships generate CONCAT(MD5gen(r_user_id_str), MD5gen(user_id_str)) as rowkey:chararray,
    r_user_id, r_screen_name,
    user_id, screen_name;

/*******************************************************************************
 * HBaseStorage
 * Be careful, add SPACE at the end of each field "colfam:cqual<SPACE>"
 * and they must be in the same order
 ******************************************************************************/


store tweets into 'hbase://tweets' using org.apache.pig.backend.hadoop.hbase.HBaseStorage('
    t:c_lng, t:c_lat, t:date_time, t:year, t:month, t:day, t:week, t:hour, t:minute, t:second, 
    e:hashtags_str, e:user_mentions_str, 
    t:favorite_count, t:filter_level, t:g_lat, t:g_lng, t:id, t:id_str, t:in_reply_to_screen_name, t:in_reply_to_status_id, t:in_reply_to_status_id_str, t:in_reply_to_user_id, t:in_reply_to_user_id_str, t:lang, 
    p:bb_lng, p:bb_lat, t:possibly_sensitive, t:retweet_count, t:source, t:text, t:truncated 
    u:followers_count, u:user_id u:user_id_str, u:screen_name');

store mentions into 'hbase://mentions' using org.apache.pig.backend.hadoop.hbase.HBaseStorage('f:user_id, f:screen_name, f:r_user_id, f:r_screen_name');

store mentioned into 'hbase://mentioned' using org.apache.pig.backend.hadoop.hbase.HBaseStorage('f:r_user_id, f:r_screen_name, f:user_id, f:screen_name');
