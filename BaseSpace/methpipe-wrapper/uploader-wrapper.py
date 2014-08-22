import os
import subprocess
import json
import sys

class DockerApp:
    def __init__(self):
        appconf = "/data/input/AppSession.json" if len(sys.argv) == 1 \
          else sys.argv[1]
        jf = json.load(open(appconf))
        properties = jf["Properties"]["Items"]
        properties = dict(zip([p["Name"] for p in properties], properties))

        self.app = "/home/methpipe/methpipe-wrapper/uploader.sh"

        self.url = properties["Input.url"]["Content"]

        self.outProjID = properties["Input.project-id"]["Content"]["Id"]

        self.outdir = "/data/output/appresults/" + self.outProjID \
          + "/" + "uploaded"

    def run(self):
        if not os.path.exists(self.outdir):
            os.makedirs(self.outdir)
        command_list = [self.app, self.outdir, self.url]    
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("Exited abnormally")

#the entry point
if __name__ == "__main__" :
    DockerApp().run()


    
