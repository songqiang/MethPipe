import os
import subprocess
import json

class DockerApp:
    def __init__(self):
        jf = json.load(open("/data/input/AppSession.json"))
        properties = jf["Properties"]["Items"]
        properties = dict(zip([p["Name"] for p in properties], properties))

        self.InAppResultID = properties["Input.AppResults"]["Items"][0]["Id"]
        self.methfile = properties["Input.meth-file"]["Content"]["Path"p]
        self.desertSize = properties["Input.desert-size"]["Content"]
        self.numIter = properties["Input.num-iter"]["Content"]
        self.outProjID = properties["Input.project-id"]["Content"]["Id"]
        self.computePMD = "-partial" if "Input.do-pmd" in properties else ""
        self.verbose = "-verbose" if "Input.verbose" in properties else ""

        self.app = "/home/methpipe/methpipe/bin/hmr"
        self.infile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.methpipe
        self.outfile = "/data/output/appresults/" + self.outProjID \
          + "/" + self.methpipe.replace(".meth", ".hmr")
          
    def runApp(self):
        command_list = [app, "-itr", numIter, "-desert", desertSize, \
                    computePMD, verbose, "-out", outfile, infile]
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("fastqc process exited abnormally")

#the entry point
if __name__ == "__main__" :
    DockerApp().run()

