

exports.tables = 'show tables'
exports.all_tweets = 'select * from tweets'
exports.all_mentions = 'select * from mentions'
exports.all_mentioned = 'select * from mentioned'
exports.geolocated_tweets = 'select * from (select year, month, day, hour, minute, second, coalesce(c_lng, g_lng, bb_lng) as lng, coalesce(c_lat, g_lat, bb_lat) as lat, text from tweets) geolocated_tweets where lng is not null and lat is not null order by year, month, day, hour, minute, second'