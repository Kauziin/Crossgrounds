"""Extract read-only QA frames from the user's local reference; never imports audio."""
from pathlib import Path
import subprocess,sys,hashlib
sys.path.insert(0,str(Path.home()/'AppData/Local/Temp/codex-ax50-video-tools'))
import imageio_ffmpeg
source=Path('instructions/Arsenal/#2a/Polar - AX-50 SNIPER SOUND EFFECT (CALL OF DUTY MODERN WARFARE).mkv')
out=Path('artifacts/ax50-storyboard-2026-11-02/reference');out.mkdir(parents=True,exist_ok=True)
exe=imageio_ffmpeg.get_ffmpeg_exe()
meta=subprocess.run([exe,'-hide_banner','-i',str(source)],capture_output=True,text=True).stderr
(out/'metadata.txt').write_text(meta+'\nSHA256 '+hashlib.sha256(source.read_bytes()).hexdigest(),encoding='utf-8')
for time in [.233,1.3]:
 subprocess.run([exe,'-hide_banner','-loglevel','error','-y','-ss',str(time),'-i',str(source),'-frames:v','1',str(out/f'{time}.jpg')],check=True)
print(meta[:1800])
