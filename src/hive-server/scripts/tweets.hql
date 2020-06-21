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

-- Name(Signature): COALESCE(T v1, T v2, ...)
-- Return Type: T
-- Description: Return the first v that is not NULL, or NULL if all v's are NULL

select * from (
    select year, month, day, hour, minute, second,
        coalesce(c_lng, g_lng, bb_lng) as lng, coalesce(c_lat, g_lat, bb_lat) as lat,
        text
    from tweets
) geolocated_tweets
where lng is not null and lat is not null
order by year, month, day, hour, minute, second;
