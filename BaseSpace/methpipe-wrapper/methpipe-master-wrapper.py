import os
import subprocess
import json
import sys

import tempfile

import numpy as np
import matplotlib as mpl
mpl.use("Agg")
import matplotlib.pyplot as plt

import xml.etree.ElementTree as ET

class DockerApp:
    def __init__(self):
        self.appconf = "/data/input/AppSession.json" if len(sys.argv) == 1 \
                else sys.argv[1]
        
    def run(self):
        self.parse_session_config_file()
        self.gen_methpipe_script()
        self.run_methpipe_script()
        self.gen_reports()

    def parse_session_config_file(self):
        jf = json.load(open(self.appconf))
        properties = jf["Properties"]["Items"]
        properties = dict(zip([p["Name"] for p in properties], properties))
        
        # input files
        self.InAppResultID = properties["Input.AppResults"]["Items"][0]["Id"]
        self.genomefile = properties["Input.genome-file"]["Content"]["Path"]
        self.genomefile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.genomefile

        self.readFileTRich = properties["Input.fastq-file-T-rich"]["Content"]["Path"]
        self.readFileTRich = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.readFileTRich

        self.readFileARich = properties["Input.fastq-file-T-rich"]["Content"]["Path"]
        self.readFileARich = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.readFileARich

        # output directories
        self.outProjID = properties["Input.project-id"]["Content"]["Id"]
        self.outDir = os.path.join(os.path.join("/data/output/appresults/" \
                                                + self.outProjID), \
                                   "/meth/")

        # parse mapping options
        self.max_mismatch = properties["Input.max-mismatch"]["Content"]
        self.max_map = properties["Input.max-mapping-locs"]["Content"]
        self.adapter = "X" if not "Input.adapter-seq" in properties else \
          properties["Input.adapter-seq"]["Content"]

        # parse methcount options
        self.maxReadLen = properties["Input.max-read-length"]["Content"]
        self.maxMismatches = properties["Input.max-mismatch"]["Content"]
        self.nonCpG = "-non" if "Input.non-CpG" in properties else ""

        # parse HMR options
        self.desertSize = properties["Input.desert-size"]["Content"]
        self.numIter = properties["Input.num-iter"]["Content"]
        self.computePMD = "-partial" if "Input.do-pmd" in properties else ""

        # TODO: parse AMR options

    def gen_methpipe_script(self):
        script_template = """#!  /bin/bash
export PATH=$PATH:/home/methpipe/methpipe/bin/
export LC_ALL=C
export ID=$(basename {readfile1} _1.fq)
cd {outDir}        
rmapbs-pe -chrom {genomefile} -mismatch {mismatch} -max-map {maxmap} -clip {adapter} {readfile1} {readfile2} -out ${{ID}}.mr -verbose

sort -k1,1 -k2,2 -k3,3 -k6,6 | duplicate-remover -stdin -stats ${{ID}}.dupstats --verbose -o ${{ID}}.uniq.mr

methcounts -chrom {genomefile} -M {mismatch} -S ${{ID}}.methstats -verbose ${{ID}.uniq.mr} -o ${{ID}}.meth

hmr -o ${{ID}}.hmr -desert {desert} -itr {hmr_itr} -verbose -p ${{ID}}.hmrparams ${{ID}}.meth -v
"""
        script = script_template.format(genomefile = self.genomefile, \
                                                    readfile1 = self.readFileTRich, \
                                                    readfile2 = self.readFileARich, \
                                                    mismatch = self.max_mismatch, \
                                                    maxmap = self.max_map, \
                                                    adapter = self.adapter, \
                                                    desert = self.desertSize, \
                                                    hmr_itr = self.numIter)

        if not os.path.exists(self.outDir):
            os.makedirs(self.outDir)

        self.script_file = open(os.path.join(self.outDir, "methpipe-script.sh"), "w")
        self.script_file.write(script)
        self.script_file.close()

    def run_methpipe_script(self):   
        command_list = ["source", os.path.join(self.outDir, "methpipe-script.sh")]
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("methcounts process exited abnormally")

    def gen_reports(self):
        # conversion rate along reads
        bs_rate_a = np.loadtxt(self.bsratefile, skiprows = 4)
        idx = bs_rate_a[:, 9] > 0
        plt.scatter(bs_rate_a[idx, 0], bs_rate_a[idx, 9])
        plt.xlim(0, 100)
        plt.ylim(ymax = 1)
        plt.xlabel("position in reads")
        plt.ylabel("conversion rate")
        plt.savefig(self.bsratefile + ".png", format = "png")
        plt.close()

        # methylation level histogram
        meth_cov = np.loadtxt(self.methfile, usecols = (4, 5))
        plt.hist(meth_cov[meth_cov[:, 1] > 0, 0], bins = 20)
        plt.savefig(self.methfile + ".png", format = "png")
        plt.close()

        # build XML summary file
        xml_root = ET.Element("summary")
        siteNum = ET.SubElement(xml_root, "siteNum")
        siteCovered = ET.SubElement(xml_root, "siteCovered")
        fraction = ET.SubElement(xml_root, "fraction")
        maxCoverage = ET.SubElement(xml_root, "maxCoverage")
        meanCoverage = ET.SubElement(xml_root, "meanCoverage")
        meanCoverageNZ = ET.SubElement(xml_root, "meanCoverageNZ")
        meanMeth = ET.SubElement(xml_root, "meanMeth")
        bsrate = ET.SubElement(xml_root, "bsrate")

        f = open(self.methstatsfile, "r")
        l = f.readline()
        siteNum.text = l[(l.find(":") + 2):]
        l = f.readline()
        siteCovered.text = l[(l.find(":") + 2):]
        l = f.readline()
        fraction.text = l[(l.find(":") + 2):]
        l = f.readline()
        maxCoverage.text = l[(l.find(":") + 2):]
        l = f.readline()
        meanCoverage.text = l[(l.find(":") + 2):]
        l = f.readline()
        meanCoverageNZ.text = l[(l.find(":") + 2):]
        l = f.readline()
        meanMeth.text = l[(l.find(":") + 2):]
        f.close()

        f = open(self.bsratefile, "r")
        l = f.readline()
        bsrate.text = l[(l.find("=") + 2):]
        f.close()

        xml_tree = ET.ElementTree(xml_root)
        xml_tree.write(self.methfile.replace(".meth", ".summary.xml"))

            
#the entry point
if __name__ == "__main__" :
    DockerApp().run()


    
