
const query = {
  main: '/tweets/words/main',
  frequency: '/tweets/words/frequency'
}

window.onload = async ()=>{
  WordCloud(document.getElementById('canvas1'), { list: (await axios.get(`http://localhost:3005${query.frequency}`)).data, gridSize: Math.round(document.getElementById('canvas1').width / 2024), fontWeight: 30 } )
  WordCloud(document.getElementById('canvas2'), { list: (await axios.get(`http://localhost:3005${query.main}`)).data, gridSize: Math.round(document.getElementById('canvas2').width / 2024), fontWeight: 30 } )
}