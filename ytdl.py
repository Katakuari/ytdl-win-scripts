import webbrowser
import PySimpleGUI as sg
import threading
import os
import yt_dlp
from pathlib import Path

######################################## GLOBAL VARS ########################################
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
ffmpeg = f'{ROOT_DIR}\\ffmpeg\\bin'

yt_dlp.utils.bug_reports_message = lambda: ''

######################################## FUNCTIONS ########################################
class Logger:
    def debug(self, msg):
        # For compatibility with youtube-dl, both debug and info are passed into debug
        # You can distinguish them by the prefix '[debug] '
        if msg.startswith('[debug] '):
            pass
        else:
            self.info(msg)

    def info(self, msg):
        pass

    def warning(self, msg):
        pass

    def error(self, msg):
        print(msg)


def ytdl(ytlink, config):
    with yt_dlp.YoutubeDL(config) as ydl:
        threading.Condition().acquire()
        ydl.download([f'{ytlink}'])
        threading.Condition().release()
        threading.Condition().notify_all()
        

def ytdlupdate():
    # TODO: Make this work
    try:
        yt_dlp.run_update()
    except ValueError as e:
        print(f'Update failed with reason:\n{e}')


def main():
######################################## PySimpleGUI ########################################
    sg.theme('Dark Blue 3')

    menubar_layout = [
        ['&File', ['&Update YTDL', '&Quit']],
        ['&Help', ['&Github', '&About']]
    ]

    leftCol_layout = [
        [sg.Frame('Output formats', [
            [sg.Radio('MP4 (Video)', 1, key='FORMAT_MP4', enable_events=True, default=True)],
            [sg.Radio('M4A (Audio)', 1, key='FORMAT_M4A', enable_events=True)],
            [sg.Radio('MP3 (Audio)', 1, key='FORMAT_MP3', enable_events=True)],
            [sg.Checkbox('Keep Video after processing', key='CB_KEEP', enable_events=True, default=False)]
        ])],
        [sg.Frame('Download destination', [
            [sg.Radio('Downloads', 2, key='DEST_DOWNLOADS', enable_events=True, default=True)],
            [sg.Radio('Custom destination', 2, key='DEST_CUSTOM', enable_events=True),
             sg.FolderBrowse(button_text='Browse...', key='DEST_CUSTOM_SEL', target='DEST_CUSTOM_CUR', initial_folder="C:/", enable_events=True)],
            [sg.Text(size=(40, 1), key='DEST_CUSTOM_CUR', relief=sg.RELIEF_SUNKEN)]
        ])]
    ]

    rightCol_layout = [
        [sg.Text('Youtube link:'), sg.Input(key='YT_LINK')],
        [sg.Button('Download', key='B_DOWNLOAD', expand_x=True, enable_events=True)],
        [sg.Multiline(key='CON_OUT', size=(60, 12), autoscroll=True, do_not_clear=True, auto_refresh=True)]
    ]

    layout = [
        [sg.Menubar(menubar_layout)],
        [sg.Column(leftCol_layout, expand_y=True, expand_x=False, element_justification='center'),
         sg.Column(rightCol_layout, expand_y=True, expand_x=False, element_justification='left')]
    ]

    window = sg.Window('Youtube-dl PySimpleGUI', layout, border_depth=1, resizable=False, finalize=True)
    window.bind('<Configure>', 'WinEvent')
    window.set_min_size((window.size[0]+5, window.size[1]+5))
    window.bring_to_front()
######################################## PySimpleGUI END ########################################

    while True:
        event, values = window.read(timeout=1000)

        # Quit application
        if event == sg.WIN_CLOSED or event == 'Quit':
            break

        # Menubar
        if event == 'Update YTDL': 
            updthread = threading.Thread(target=ytdlupdate)
            sg.Popup('YT-DLP now updating...')
            updthread.start()
            updthread.join()
            
        if event == 'About': sg.PopupOK('A Python script written by Katakuari.\nTwitter: @ItsKatakuari\nGithub: https://github.com/Katakuari', title='About ytdl.py')
        if event == 'Github': webbrowser.open(url="https://github.com/Katakuari/ytdl-win-scripts")

        # Left column: Format button functions
        if values['FORMAT_MP4'] is True:
            ydl_opts = {
                'format': '(bestvideo[height=1080][fps>30][ext=mp4]+bestaudio[ext=m4a])/(bestvideo[height=1080][ext=mp4]+bestaudio[ext=m4a])/(bestvideo[height=1080][ext=mp4]+bestaudio[ext=m4a])/(bestvideo[height=720][fps>30][ext=mp4]+bestaudio[ext=m4a])/bestvideo[ext=mp4]+bestaudio[ext=m4a]/(bestvideo[ext=mp4]+bestaudio[ext=m4a])/best[ext=mp4]',
                'geo_bypass': True,
                'source_address': '0.0.0.0',
                'ffmpeg_location': f'{ffmpeg}',
                'newline': True,
                'logger': Logger(),
            }

        if values['FORMAT_M4A'] is True:
            ydl_opts = {
                'format': 'bestaudio[ext=m4a]',
                'geo_bypass': True,
                'source_address': '0.0.0.0',
                'ffmpeg_location': f'{ffmpeg}',
                'newline': True,
                'logger': Logger(),
                'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'm4a',
                    'preferredquality': '192', }]
            }

        if values['FORMAT_MP3'] is True:
            ydl_opts = {
                'format': 'bestaudio',
                'geo_bypass': True,
                'source_address': '0.0.0.0',
                'ffmpeg_location': f'{ffmpeg}',
                'newline': True,
                'logger': Logger(),
                'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192', }]
            }

        if values['CB_KEEP'] is True: ydl_opts['keepvideo'] = True
        if values['CB_KEEP'] is False: ydl_opts.pop("'keepvideo'", 'keep not found')

        # Left column: Destination button functions
        # Set Radio to custom destination upon choosing folder
        if ((event == 'WinEvent') and (values['DEST_CUSTOM_SEL'] != '') and (values['DEST_CUSTOM'] is False)): window['DEST_CUSTOM'].update(value=True)
        
        if ((values['DEST_CUSTOM'] is True) and (values['DEST_CUSTOM_SEL'] != '')):
            dldest = values['DEST_CUSTOM_SEL']
            # TODO: Catch PermissionException
            os.chdir(dldest)
            # print(os.getcwd())

        if values['DEST_DOWNLOADS'] is True:
            dldest = str(Path.home())+"\Downloads"
            os.chdir(dldest)

        # Download action
        if event == 'B_DOWNLOAD':
            if (values['YT_LINK'] == ''): sg.PopupOK('Please insert YouTube link!', title='ERROR'); continue

            dlthread = threading.Thread(target=ytdl, args=(values['YT_LINK'], ydl_opts), daemon=True)
            dlthread.start()
            #dlthread.join()

            window['CON_OUT'].update(Logger())


        print(ydl_opts)
        #print(event, values)

    window.close()


if __name__ == '__main__':
	main()