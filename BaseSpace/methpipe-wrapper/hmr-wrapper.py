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

        self.InAppResultID = properties["Input.AppResults"]["Items"][0]["Id"]
        self.methfile = properties["Input.meth-file"]["Content"]["Path"]
        self.desertSize = properties["Input.desert-size"]["Content"]
        self.numIter = properties["Input.num-iter"]["Content"]
        self.outProjID = properties["Input.project-id"]["Content"]["Id"]
        self.computePMD = "-partial" if "Input.do-pmd" in properties else ""
        self.verbose = "-verbose"

        self.app = "/home/methpipe/methpipe/bin/hmr"
        self.infile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.methfile
        self.outfile = "/data/output/appresults/" + self.outProjID \
          + "/" + self.methfile.replace(".meth", ".hmr")
          
    def run(self):
        outdir = os.path.dirname(self.outfile)
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        command_list = [self.app, "-itr", self.numIter, \
                        "-desert", self.desertSize, \
                        self.computePMD, self.verbose, "-out", \
                        self.outfile, self.infile]
        print "\t".join(command_list)
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("fastqc process exited abnormally")

#the entry point
if __name__ == "__main__" :
    DockerApp().run()


    
