
const query = {
  geo: '/tweets/geolocated',
}



window.onload = async ()=>{
  const map = L.map('map').setView([40.4184, -3.6920], 7)
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'}).addTo(map)
  axios.get(`http://localhost:3005${query.geo}`).then((response)=>{
    response.data.forEach(tweet => {
      L.marker([Number(tweet[7]), Number(tweet[6])]).addTo(map).bindPopup(tweet[8])
    })
  })
}
