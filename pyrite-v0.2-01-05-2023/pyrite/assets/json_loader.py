import json

class JsonLoader:
    def read_path(self, path):
        with open(path, 'r') as file:
            json_data = json.load(file)
        return json_data

    def write(self, prefix, data):
        with open('self.path', 'r') as file:
            json_data = json.load(file)
            json_data['prefix'] = data
                
        with open('self.path', 'w') as file:
            json.dump(json_data, file, indent=2)
            
def read_path(path):
        with open(path, 'r') as file:
            json_data = json.load(file)
        return json_data