import webbrowser
import PySimpleGUI as sg
import subprocess
import os

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))


# PySimpleGUI
sg.theme('Dark Blue 3')

menubar_layout = [
    ['&File', ['&Config files', '&Quit']],
    ['&Help', ['&Github', '&About']]
]

leftCol_layout = [
    [sg.Frame('Output formats', [
        [sg.Radio('MP4 (Video)', 1, key='FORMAT_MP4',
                  enable_events=True, default=True)],
        [sg.Radio('M4A (Audio)', 1, key='FORMAT_M4A', enable_events=True)],
        [sg.Radio('MP3 (Audio)', 1, key='FORMAT_MP3', enable_events=True)],
        [sg.Checkbox('Keep original files after download',
                     key='CB_KEEP', enable_events=True, default=False)]])
     ],

    [sg.Frame('Download destination', [
        [sg.Radio('Downloads', 2, key='DEST_DOWNLOADS',
                  enable_events=True, default=True)],
        [sg.Radio('Custom destination', 2, key='DEST_CUSTOM',
                  enable_events=True), sg.FolderBrowse(button_text='Browse...', key='DEST_CUSTOM_SEL', target='DEST_CUSTOM_CUR', initial_folder="C:/", enable_events=True)],
        [sg.Text(size=(40, 1), key='DEST_CUSTOM_CUR', relief=sg.RELIEF_SUNKEN)]

    ]
    )]
]

rightCol_layout = [
    [sg.Text('Youtube link:'), sg.Input(key='YT_LINK')],
    [sg.Button('Download', key='B_DOWNLOAD', expand_x=True,
               enable_events=True)],
    [sg.Text(key='CON_OUT', size=(50, 12), relief=sg.RELIEF_SOLID)]
]

layout = [
    [sg.Menubar(menubar_layout)],
    [sg.Column(leftCol_layout, expand_y=True, expand_x=False, element_justification='center'),
     sg.Column(rightCol_layout, expand_y=True, expand_x=False, element_justification='left')],
]

window = sg.Window('Youtube-dl', layout,
                   border_depth=1, resizable=False, finalize=True)
window.bind('<Configure>', 'WinEvent')
window.set_min_size((window.size[0], window.size[1]))
window.bring_to_front()

while True:
    event, values = window.read()

    # Quit application
    if event == sg.WIN_CLOSED or event == 'Quit':
        break

    # Menubar
    if event == 'Config files':
        subprocess.run(r'explorer "[ROOT_DIR/configs/]"')

    if event == 'About':
        sg.popup_ok('A Python script written by Katakuari.\nTwitter: @ItsKatakuari\nGithub: https://github.com/Katakuari',
                    title='About ytdl.py')

    if event == 'Github':
        webbrowser.open(url="https://github.com/Katakuari/ytdl-win-scripts")

    # Left column: Format button functions
    if values['CB_KEEP'] == True:
        keep = "-k"
        print(keep)
    elif values['CB_KEEP'] == False:
        keep = ""
        print(keep)

    if values['FORMAT_MP4'] == True:
        config = "./configs/configmp4.txt"
        print('MP4 CHOSEN')

    if values['FORMAT_M4A'] == True:
        config = "./configs/configm4a.txt"
        print('M4A CHOSEN')

    if values['FORMAT_MP3'] == True:
        config = "./configs/configmp3.txt"
        print('MP3 CHOSEN')

    # Left column: Destination button functions
    # Set Radio to custom destination upon choosing folder
    if event == 'WinEvent' and values['DEST_CUSTOM_SEL'] != '' and values['DEST_CUSTOM'] == False:
        window['DEST_CUSTOM'].update(value=True)

    if values['DEST_CUSTOM'] == True and values['DEST_CUSTOM_SEL'] != '':
        dldest = values['DEST_CUSTOM_SEL']

    # if values['DEST_DOWNLOADS'] == True:
        # dldest =  TO DO

    # Download function
    if event == 'B_DOWNLOAD':
        # TO DO
        subprocess.Popen(executable='[ROOT_DIR]/youtube-dl.exe',
                         args="--ffmpeg-location [ROOT_DIR]/ffmpeg/bin --config-location [ROOT_DIR]/configs/[config] [YT_LINK]", stdout=values['CON_OUT'])

    print(event, values)

window.close()
