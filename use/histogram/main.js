
const query = {
  sentiment: '/tweets/sentiment/histogram',
}

function drawChart (canvas, data) {
  const to_label = data.map((value, index)=>{return `${(index>10?(index+1 - data.length/2)/data.length*200 : (index - data.length/2)/data.length*200).toFixed(0)}%`})
  const barChart = new Chart(document.getElementById(canvas), {
    type: 'bar',
    data: {
      labels: to_label,
      datasets: [{
          label: 'Sentiment analysis',
          data: data
        }
      ]
    },
    options: {
        responsive: false
    }
  })
}

window.onload = ()=>{
  
  axios.get(`http://localhost:3005${query.sentiment}`).then((response)=>{
    drawChart('canvas1', response.data.ml)
    drawChart('canvas2', response.data.simple)
  })
}