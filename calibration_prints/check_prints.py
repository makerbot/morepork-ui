import json 
import os
import zipfile

BOT_TYPES = {
    'fire': 'fire_e',
    'lava': 'lava_f',
    'magma': 'magma_10'}

EX2_LOOKUP = {
    'pva': 'mk14_s',
    'sr30': 'mk14_hot_s',
    'hips': 'mk14_hot_s',
    'wss1': 'mk14_hot_s'}

def check_slice(path, bot_type, ex1, mat1, mat2):
    if mat2 not in EX2_LOOKUP:
        raise Exception('Unknown support material %r for slice %s' %
            (mat2, path))
    ex2 = EX2_LOOKUP[mat2]
    with zipfile.ZipFile(path) as z:
        with z.open('meta.json') as f:
            meta = json.loads(f.read().decode('utf8'))
    if meta['bot_type'] != bot_type:
        raise Exception('Bad bot type %r for slice %s' %
            (meta['bot_type'], path))
    if meta['tool_types'][0] != ex1:
        raise Exception('Bad model extruder %r for slice %s' %
            (meta['tool_types'][0], path))
    if meta['tool_types'][1] != ex2:
        raise Exception('Bad support extruder %r for slice %s' %
            (meta['tool_types'][1], path))
    if meta['materials'][0] != mat1:
        raise Exception('Bad model material %r for slice %s' %
            (meta['materials'][0], path))
    if meta['materials'][1] != mat2:
        raise Exception('Bad support material %r for slice %s' %
            (meta['materials'][1], path))

def check_prints(path, bot_type, ex1):
    for slice in os.listdir(path):
        if not slice.endswith('.makerbot'): continue
        name_parts = slice[:-9].split('_')
        if len(name_parts) != 3 or name_parts[0] != 'calibration':
            raise Exception('Bad slice name ' + slice)
        slice_path = os.path.join(path, slice)
        check_slice(slice_path, bot_type, ex1, *name_parts[1:])

def check_bot(path, bot_type):
    for ex1 in os.listdir(path):
        check_prints(os.path.join(path, ex1), bot_type, ex1)

def check_all():
    path = os.path.dirname(__file__)
    if not path: path = '.'
    for name in os.listdir(path):
        if name not in BOT_TYPES: continue
        check_bot(os.path.join(path, name), BOT_TYPES[name])

if __name__ == '__main__':
    check_all()
