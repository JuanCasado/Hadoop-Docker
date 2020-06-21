
function clear_xml (text) {
  return text.replace(/<[^>]*>/g, '').replace('Twitter for Android', '').replace('Twitter for iPad', '').replace('Twitter for iPhone', '').trim()
}

function clear_mentions (text) {
  return text.replace(/@[A-Za-z0-9_]+/g, '').replace('RT :', '').trim()
}

function clear_url (text) {
  return text.replace(/(?:https?|ftp):\/\/[\n\S]+/g, '').trim()
}

function apply_clear (grid, clearers, to_clears) {
  return grid.map((line)=>{
    for (to_clear of to_clears)
      for (clearer of clearers)
        if (line[to_clear]) 
          line[to_clear] = clearer(line[to_clear])
    return line
  })
}

function longest_of (grid, to_compare) {
  return grid.map((line)=> {
    let longest = ''
    for (in_compare of to_compare)
      if (line[in_compare] && line[in_compare]!=='0' && line[in_compare]!=='NULL' && line[in_compare]!=='false' && isNaN(line[in_compare]) && line[in_compare].length > longest.length)
        longest = line[in_compare]
    return longest
  })
}

function make_unique (list) {
  return [...new Set(list)].filter((elem)=>{return elem!==''})
}

exports.xml = clear_xml
exports.mentions = clear_mentions
exports.url = clear_url
exports.apply = apply_clear
exports.longest = longest_of
exports.unique = make_unique
