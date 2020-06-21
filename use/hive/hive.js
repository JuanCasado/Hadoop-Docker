
const { performance } = require('perf_hooks')
const { setInterval, clearInterval } = require('timers')
const spawn = require('child_process').spawn

let killed = false
let hive = null
let isHiveReady = false
let hiveBufferEnabled = false
let hiveBuffer = ''
let answerRequest = null
let currentRequest = ''

function init () {
  if (killed) {killed = false; return}
  hive = spawn('docker', ['exec', '-i', 'hive-server', 'hive'])
  isHiveReady = false
  hiveBufferEnabled = false
  hiveBuffer = ''
  // STDOUT
  hive.stdout.on('data', (data) => {
    if (isHiveReady && hiveBufferEnabled) {
      if (data.toString().includes('hive>') && answerRequest !== null) {
        answerRequest(hiveBuffer)
        disableHiveBuffer()
        answerRequest = null
        currentRequest = ''
      } else hiveBuffer+=data
    }
  })
  // STDERR
  hive.stderr.on('data', (data) => { 
    if (isHiveReady && data.toString().includes('OK')) enableHiveBuffer()
    else if (data.toString().includes('Hive-on-MR')) isHiveReady = true
  })
  // CONNeCTION CLOSED
  hive.on('close', (code) => { 
    console.log(`child process exited with code ${code}`)
    init()
  })
  if (answerRequest !== null && currentRequest !== '') {
    setTimeout (async () => {
      const answerRequestCopy = answerRequest;
      const response = await write(currentRequest)
      answerRequestCopy(response)
    }, 200)
  }
}

function enableHiveBuffer ()  { hiveBuffer = ''; hiveBufferEnabled = true }
function disableHiveBuffer () { hiveBuffer = ''; hiveBufferEnabled = false }

async function hiveReady () {
  if (isHiveReady) return
  else return new Promise ((resolve) => {
    const interval = setInterval(()=> {if (isHiveReady){resolve(); clearInterval(interval)}}, 100)
  })
}

async function hiveQuery (request) {
  hive.stdin.write(request+';\n')
  return new Promise ((resolve) => {
    answerRequest = resolve
  })
}

function responseFilter (response) {
  const lines = response.split(/[\r\n]+/).filter((line)=>(line !== ''))
  const grid = lines.map((line)=>{return line.split(/[\t]+/).map((cell)=>{return cell.replace(/[\r\n]+/, '')})})
  return grid
}

async function write (request) {
  currentRequest = request
  await hiveReady()
  return responseFilter(await hiveQuery(request))
}

async function voice_write (request) {
  console.log(request)
  const start = performance.now()
  const response = await write(request)
  const end = performance.now()
  console.log(`done in ${((end - start) / 1000).toFixed(2)}s`)
  return response
}

function close () {
  killed = true
  hive.kill()
}

init()
exports.init = init
exports.write = write
exports.voice_write = voice_write
exports.close = close