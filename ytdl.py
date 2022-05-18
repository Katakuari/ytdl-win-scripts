import webbrowser, os, subprocess
from pathlib import Path

import PySimpleGUI as sg    # python3 -m pip install -U PySimpleGUI
import yt_dlp               # python3 -m pip install -U yt_dlp

######################################## GLOBAL VARS ########################################
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
ffmpeg = f'{ROOT_DIR}/ffmpeg/bin'

yt_dlp.utils.bug_reports_message = lambda: ''

def main():
######################################## PySimpleGUI ########################################
    sg.theme('Dark Blue 3')

    menubar_layout = [
        ['&Info',['&About this script','&YT-DLP on Github','&PySimpleGUI']]
    ]

    leftCol_layout = [
        [sg.Frame('Output formats', [
            [sg.Radio('MP4 (Video)', 1, key='FORMAT_MP4', enable_events=True, default=True)],
            [sg.Radio('M4A (Audio)', 1, key='FORMAT_M4A', enable_events=True)],
            [sg.Radio('MP3 (Audio)', 1, key='FORMAT_MP3', enable_events=True)],
            [sg.Checkbox('Keep files after processing', key='CB_KEEP', enable_events=True, default=False)]
        ])],

        [sg.Frame('Download destination', [
            [sg.Radio('Downloads', 2, key='DEST_DOWNLOADS', enable_events=True, default=True)],
            [sg.Radio('Custom destination', 2, key='DEST_CUSTOM', enable_events=True),
            sg.FolderBrowse(button_text='Browse...', key='DEST_CUSTOM_SEL', target='DEST_CUSTOM_CUR', initial_folder="C:/", enable_events=True)],
            [sg.Text(size=(40, 1), key='DEST_CUSTOM_CUR', relief=sg.RELIEF_SUNKEN)],
            [sg.Button('Open destination', key='DEST_OPEN', expand_x=True, enable_events=True)]
        ])]
    ]

    rightCol_layout = [
        [sg.Text('Youtube link:'), sg.Input(key='YT_LINK')],
        [sg.Button('Download', key='B_DOWNLOAD', expand_x=True, enable_events=True, disabled=False)],
        [sg.Frame('Status', [
            [sg.Text(text='Click "Download" to start downloading', key='STATUS', enable_events=False, auto_size_text=True, relief=sg.RELIEF_FLAT, justification='center', expand_x=True, expand_y=True)]
        ], expand_x=True, expand_y=True)]
    ]

    layout = [
        [sg.Menubar(menubar_layout)],
        [sg.Column(leftCol_layout, expand_y=True, expand_x=False, element_justification='center'),
        sg.Column(rightCol_layout, expand_y=True, expand_x=False, element_justification='center')]
    ]

    window = sg.Window('Youtube-dl PySimpleGUI', layout, border_depth=1, resizable=False, finalize=True)
    window.bind('<Configure>', 'WinEvent')
    window.set_min_size((window.size[0]+5, window.size[1]+5))
    window.bring_to_front()
######################################## PySimpleGUI END ########################################

    while True:
        event, values = window.read(timeout=1000)

        # Quit application
        if event == sg.WIN_CLOSED:
            break

        # Print events and values to console
        if (event) and (event != "__TIMEOUT__") and (event != "WinEvent"): print(event, values)

        # Menubar
        if event == 'About this script': webbrowser.open(url="https://github.com/Katakuari/ytdl-win-scripts/blob/main/AboutPy.md")
        if event == 'YT-DLP on Github': webbrowser.open(url="https://github.com/yt-dlp/yt-dlp")
        if event == 'PySimpleGUI': webbrowser.open(url="https://pysimplegui.readthedocs.io/en/latest/")


        # Left column: Format button functions
        if values['FORMAT_MP4'] is True:
            ydl_opts = {
                'format': '(bestvideo[height=1080][fps>30][ext=mp4]+bestaudio[ext=m4a])/(bestvideo[height=1080][ext=mp4]+bestaudio[ext=m4a])/(bestvideo[height=1080][ext=mp4]+bestaudio[ext=m4a])/(bestvideo[height=720][fps>30][ext=mp4]+bestaudio[ext=m4a])/bestvideo[ext=mp4]+bestaudio[ext=m4a]/(bestvideo[ext=mp4]+bestaudio[ext=m4a])/best[ext=mp4]',
                'geo_bypass': True,
                'source_address': '0.0.0.0',
                'ffmpeg_location': f'{ffmpeg}',
                'newline': True,
                'keepvideo': False
            }

        if values['FORMAT_M4A'] is True:
            ydl_opts = {
                'format': 'bestaudio[ext=m4a]',
                'geo_bypass': True,
                'source_address': '0.0.0.0',
                'ffmpeg_location': f'{ffmpeg}',
                'newline': True,
                'keepvideo': False
            }

        if values['FORMAT_MP3'] is True:
            ydl_opts = {
                'format': 'bestaudio',
                'geo_bypass': True,
                'source_address': '0.0.0.0',
                'ffmpeg_location': f'{ffmpeg}',
                'newline': True,
                'keepvideo': False,
                'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192', }]
            }

        if values['CB_KEEP'] is True: ydl_opts['keepvideo'] = True
        if values['CB_KEEP'] is False: ydl_opts['keepvideo'] = False


        # Left column: Destination button functions
        # Set Radio to custom destination upon choosing folder
        if ((event == 'WinEvent') and (values['DEST_CUSTOM_SEL'] != '') and (values['DEST_CUSTOM'] is False)): window['DEST_CUSTOM'].update(value=True)

        if ((values['DEST_CUSTOM'] is True) and (values['DEST_CUSTOM_SEL'] != '')):
            dldest = values['DEST_CUSTOM_SEL']
            dldest = os.path.normpath(dldest)
            os.chdir(dldest)
            values['DEST_CUSTOM_SEL'] = ''


        if values['DEST_DOWNLOADS'] is True:
            dldest = str(Path.home())+"\Downloads"
            os.chdir(dldest)


        if event == 'DEST_OPEN':
            FILEBROWSER_PATH = os.path.join(os.getenv('WINDIR'), 'explorer.exe')
            subprocess.run([FILEBROWSER_PATH, f"{dldest}"])


        # Download action
        if event == 'B_DOWNLOAD':
            if (values['YT_LINK'] == ''): sg.PopupOK('Please insert link starting with "https://"!', no_titlebar=True, background_color='darkred'); continue
            if not (values['YT_LINK'].startswith('https://')): sg.PopupOK('Please insert link starting with "https://"!', no_titlebar=True, background_color='darkred'); continue

            window['STATUS'].update('Downloading...')
            window['B_DOWNLOAD'].update(disabled=True)
            window.read(timeout=100)

            with yt_dlp.YoutubeDL(ydl_opts, 'no_verbose_header') as ydl:
                try:
                    print('\n\n')
                    ydl.download(f"{values['YT_LINK']}")
                except yt_dlp.DownloadError as e:
                    sg.PopupOK(f'Error while downloading!\n\n{e.msg}\n\n{e.exc_info}', no_titlebar=True ,background_color='darkred')
                except yt_dlp.SameFileError as e:
                    sg.PopupOK(f'Downloaded file already exists!\n\n{e.msg}', no_titlebar=True ,background_color='darkred')
                except Exception as e:
                    sg.PopupOK(f'Following error occured:\n\n{e}', no_titlebar=True ,background_color='darkred')
            
            window['B_DOWNLOAD'].update(disabled=False)
            window['STATUS'].update('Download finished!')


        #print(event, values)

    window.close()


if __name__ == '__main__':
	main()