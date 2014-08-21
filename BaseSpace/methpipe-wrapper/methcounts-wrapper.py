import os
import subprocess
import json
import sys

import numpy as np
import matplotlib as mpl
mpl.use("Agg")
import matplotlib.pyplot as plt

import xml.etree.ElementTree as ET


class DockerApp:
    def __init__(self):
        appconf = "/data/input/AppSession.json" if len(sys.argv) == 1 \
          else sys.argv[1]
        jf = json.load(open(appconf))
        properties = jf["Properties"]["Items"]
        properties = dict(zip([p["Name"] for p in properties], properties))

        self.methcounts_app = "/home/methpipe/methpipe/bin/methcounts"
        self.bsrate_app = "/home/methpipe/methpipe/bin/bsrate"
        
        self.InAppResultID = properties["Input.AppResults"]["Items"][0]["Id"]
        self.genomefile = properties["Input.genome-file"]["Content"]["Path"]
        self.genomefile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.genomefile

        self.mappedReadFile = properties["Input.mr-file"]["Content"]["Path"]
        self.mappedReadFile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.mappedReadFile

        self.maxReadLen = properties["Input.max-read-length"]["Content"]
        self.maxMismatches = properties["Input.max-mismatch"]["Content"]

        self.nonCpG = "-non" if "Input.non-CpG" in properties else ""
        self.verbose = "-verbose"
        
        self.outProjID = properties["Input.project-id"]["Content"]["Id"]

        self.methfile = self.mappedReadFile.replace(".mr", ".meth")
        self.methfile = self.methfile.replace( \
            "/data/input/appresults/" + self.InAppResultID + "/", \
            "/data/output/appresults/" + self.outProjID + "/meth/")          

        self.methstatsfile = self.methfile.replace(".meth", ".methstats")
        self.bsratefile = self.methfile.replace(".meth", ".bsrate")

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
        
    def run(self):
        # run methcounts program
        command_list = [self.methcounts_app, self.mappedReadFile, \
                        "-output", self.methfile, \
                        "-output_stat", self.methstatsfile, \
                        "-chrom", self.genomefile, \
                        "-max_length", self.maxReadLen, \
                        "-max", self.maxMismatches, self.verbose]
        if not self.nonCpG: command_list.append(self.nonCpG)
        print "\t".join(command_list)
        outdir = os.path.dirname(self.methfile)
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("methcounts process exited abnormally")

        # run bsrate program
        command_list = [self.bsrate_app, self.mappedReadFile, \
                        "-output", self.bsratefile, \
                        "-chrom", self.genomefile, \
                        "-max", self.maxMismatches, self.verbose]
        print "\t".join(command_list)
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("bsrate process exited abnormally")

        self.gen_reports()    
            
#the entry point
if __name__ == "__main__" :
    DockerApp().run()


    
