
const query = {
  mentioned: '/mentioned/chart',
  mentions: '/mentions/chart',
}

function drawChart (canvas, data) {
  const scatterChart = new Chart(document.getElementById(canvas), {
    type: 'scatter',
    data: {
      datasets: [{
          label: 'Interactions',
          data: data
        }
      ]
    },
    options: {
      responsive: false,
      scales: {
        yAxes: [{scaleLabel:{
          display: true,
          labelString: (canvas==='canvas1'?'Mentions':'Mentioned')
        }}],
        xAxes: [{scaleLabel:{
          display: true,
          labelString: (canvas==='canvas1'?'Mentioned':'Mentions')
        }}]
      }
    }
  })
}

window.onload = async ()=>{
  drawChart('canvas1', (await axios.get(`http://localhost:3005${query.mentions}`)).data)
  drawChart('canvas2', (await axios.get(`http://localhost:3005${query.mentioned}`)).data)
}