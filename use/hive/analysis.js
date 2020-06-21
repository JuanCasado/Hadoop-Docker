

const hive = require('./hive')
const requests = require('./request')
const filters = require('./filters')
const lorca = require('lorca-nlp')
 
async function getAllTweets () {
  return hive.voice_write(requests.all_tweets)
}

async function getAllMentions () {
  return hive.voice_write(requests.all_mentions)
}

async function getAllMentioned () {
  return hive.voice_write(requests.all_mentioned)
}

async function getGeolocatedTweets () {
  return filters.apply(await hive.voice_write(requests.geolocated_tweets), [filters.xml, filters.url, filters.mentions], [8])
}

async function getTextTweets () {
  return filters.unique(filters.longest(filters.apply(await getAllTweets(), [filters.xml, filters.url, filters.mentions], [24, 25, 26]), [24, 25, 26]))
}

async function getSentimentTweets () {
  return (await getTextTweets()).map((text)=>{
    const doc = lorca(text)
    return {
      simple: doc.sentiment(),
      ml: doc.sentiment('senticon'),
    }
  })
}

async function getSentimentTweetsHistogram () {
  const bucket_size = 20
  const simple = Array(bucket_size*2).fill(0)
  const ml = Array(bucket_size*2).fill(0)
  const add_to_array = (value, array) => {
    const abs_value = Math.abs(value)
    const raw_index = Math.round(abs_value*bucket_size)
    const array_position = value > 0? raw_index + bucket_size : (bucket_size-1) - raw_index
    ++array[array_position]
    return array
  }
  return (await getSentimentTweets()).reduce((acc, sentiment)=> {
    return {simple: add_to_array(sentiment.simple, acc.simple), ml: add_to_array(sentiment.ml, acc.ml)}
  }, {simple, ml})
}

async function getReadabilityTweets () {
  return (await getTextTweets()).map((text)=>{
    const ifsz = lorca(text).ifsz()
    return {
      score: ifsz.get(),
      grade: ifsz.grade.get(),
    }
  })
}

async function getReadingTimeTweets () {
  return (await getTextTweets()).map((text)=>{
    return lorca(text).readingTime()
  })
}

async function getFullTextTweets () {
  return (await getTextTweets()).reduce((acc, text)=>{
    return acc+text
  }, '')
}

async function getMainWordsTweets () {
  const words = lorca(await getFullTextTweets()).tfidf().sort().get()
  return Object.entries(words).filter((entry)=>{return entry[1]!==null && entry[1] > 3 && entry[0].length>3})
}

async function getFrequencyTweets () {
  const words = lorca(await getFullTextTweets()).concordance().sort().get()
  return Object.entries(words).filter((entry)=>{return entry[1]!==null && entry[1] > 3 && entry[0].length>3})
}

async function mentionsChart () {
  const cache = new Map()
  const mentions = await getAllMentions()
  mentions.forEach(mention => {
    if (!cache.has(mention[1])) {cache.set(mention[1], {x: 0, y:0})}
    cache.set(mention[1], {x: cache.get(mention[1]).x+1, y:cache.get(mention[1]).y})
    if (!cache.has(mention[3])) {cache.set(mention[3], {x: 0, y:0})}
    cache.set(mention[3], {x: cache.get(mention[3]).x, y:cache.get(mention[3]).y+1})
  })
  return Array.from(cache.values())
}

async function mentionedChart () {
  const cache = new Map()
  const mentioned = await getAllMentioned()
  mentioned.forEach(mention => {
    if (!cache.has(mention[1])) {cache.set(mention[1], {x: 0, y:0})}
    cache.set(mention[1], {x: cache.get(mention[1]).x+1, y:cache.get(mention[1]).y})
    if (!cache.has(mention[3])) {cache.set(mention[3], {x: 0, y:0})}
    cache.set(mention[3], {x: cache.get(mention[3]).x, y:cache.get(mention[3]).y+1})
  })
  return Array.from(cache.values())
}

exports.getAllTweets = getAllTweets
exports.getAllMentions = getAllMentions
exports.getAllMentioned = getAllMentioned
exports.getGeolocatedTweets = getGeolocatedTweets
exports.getTextTweets = getTextTweets
exports.getSentimentTweets = getSentimentTweets
exports.getSentimentTweetsHistogram = getSentimentTweetsHistogram
exports.getReadabilityTweets = getReadabilityTweets
exports.getFullTextTweets = getFullTextTweets
exports.getMainWordsTweets = getMainWordsTweets
exports.getFrequencyTweets = getFrequencyTweets
exports.getReadingTimeTweets = getReadingTimeTweets
exports.mentionsChart = mentionsChart
exports.mentionedChart = mentionedChart
