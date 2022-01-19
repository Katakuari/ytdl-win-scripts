import PySimpleGUI as sg
import os
import io


sg.theme('System Default 1')

menubar_layout = [
    ['File', ['Config files', 'Quit']],
    ['Help', ['Info', 'About']]
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
                  enable_events=True), sg.Button('Change...', key='DEST_CUSTOM_SEL', file_types='Folder', initial_folder='C:/Users/%USER%/Downloads')],
        [sg.Input(key='DEST_CUSTOM_CUR', readonly=True)]
    ]
    )]
]

rightCol_layout = [
    [sg.Text('Youtube link:'), sg.Input(key='YT_LINK')],
    [sg.Button('Download', key='B_DOWNLOAD', expand_x=True,
               enable_events=True), sg.Exit()]
]

layout = [
    [sg.Menubar(menubar_layout)],
    [sg.Column(leftCol_layout, expand_y=True, expand_x=False, element_justification='center'),
     sg.Column(rightCol_layout, expand_y=True, expand_x=False, element_justification='left')],
]

window = sg.Window('Youtube-dl', layout,
                   border_depth=1, resizable=False, finalize=True)
window.bind('<Configure>', 'WinEvent')
window.set_min_size((window.size[0], window.size[1]+30))
window.bring_to_front()

while True:
    event, values = window.read()

    # Quit application
    if event == sg.WIN_CLOSED or event == 'Exit':
        break

    print(event, values)

window.close()
