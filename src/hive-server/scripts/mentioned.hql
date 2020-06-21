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

-- Name(Signature): substr(string|binary A, int start, int len) 
-- Return Type: string
-- Description: Returns the substring or slice of the byte array of A starting
--      from start position with length len
--      e.g. substr('foobar', 4, 1) results in 'b'

-- e.g. screen_name = 'FIFAcom' fue mencionado por...
select r_screen_name, user_id
from mentioned
where substr(key, 1, 32) = 'E36B945A1601DEFAE40B28565818A832';
