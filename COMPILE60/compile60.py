## Project: COMPILE60
## Module: Build system in a dialog for PC-6001 N66/SR BASIC
## Author: Salwan

import os
import json
import urllib2
import subprocess
from Tkinter import *
import tkMessageBox
import tkFont
import tkFileDialog

__author__ = "Salwan"

CONF_PATH = "./.vscode/"
BUILD_PATH = "./build/"
ZCC_EXE = "zcc.exe"
ZCC_CONFIG_VAR = "ZCCCFG"

# Progress bar colors (PC60 colors)
BAR_DEFAULT = '#ADAEAD'
BAR_BUSY_1 = '#FFAE00'
BAR_BUSY_2 = '#FF00AD'
BAR_BUSY_3 = '#FFFF00'
BAR_SUCCESS = '#ADFF00'
BAR_FAIL = '#FF0000'

COMPILE_TEMPLATE = """{{
    "version": "2.0.0",
    "compile60": {{
        "buildName": "{buildName}",
        "mode": {buildMode},
        "libsList": [{listOfLibraries}],
        "libsLinked": [{linkLibraries}],
        "outputPath": "{outputPath}",
        "codeFiles": {codeFiles}
    }},
    "tasks": [
        {{
			"id": "n60r32",
            "label": "PC-6001 N60 Build (Mode 4 Page 2)",
            "type": "shell",
            "command": "zcc.exe",
            "args": [
                "+pc6001", "-subtype=32k",
                "-o'${{fileBasenameNoExtension}}.bin'",
                "${{fileBasename}}",
                "-create-app"
                {libraries0}
            ],
            "group": "build",
            "presentation": {{
                "reveal": "always"
            }}
        }},
        {{
			"id": "n60r16",
            "label": "PC-6001 N60 Build (Mode 3 Page 2)",
            "type": "shell",
            "command": "zcc.exe",
            "args": [
                "+pc6001", "-subtype=16k",
                "-o'${{fileBasenameNoExtension}}.bin'",
                "${{fileBasename}}",
                "-create-app"
                {libraries1}
            ],
            "group": "build",
            "presentation": {{
                "reveal": "always"
            }}
        }},
        {{
		    "id": "n66",
            "label": "WIP PC-6001 N66 Build (Mode 5 Page 3)",
            "type": "shell",
            "command": "zcc.exe",
            "args": [
                "+pc6001", "-subtype=n60m",
                "-o'${{fileBasenameNoExtension}}.bin'",
                "${{fileBasename}}",
                "-create-app"
                {libraries2}
            ],
            "group": "build",
            "presentation": {{
                "reveal": "always"
            }}
        }},
        {{
			"id": "n66sr",
            "label": "WIP PC-6001 N66 SR Build (Mode 6)",
            "type": "shell",
            "command": "zcc.exe",
            "args": [
                "+pc6001", "-subtype=n66sr",
                "-o'${{fileBasenameNoExtension}}.bin'",
                "${{fileBasename}}",
                "-create-app"
                {libraries3}
            ],
            "group": "build",
            "presentation": {{
                "reveal": "always"
            }}
        }}
    ]
}}
"""

SubtypeOptions = {
            0:"N60 16KB (Mode 3 Page 2)",
            1:"N60 32KB (Mode 4 Page 2)",
            2:"N66 64KB (Mode 5 Page 3)",
            3:"N66 SR 64KB (Mode 6)"
}

SubtypeIdToOption = [
    "n60r16",
    "n60r32",
    "n60m",
    "n66sr"
]

StandardLibraries = {
    "Math":"m", 
    "N-DOS":"ndos"
}

class Application:
    def __init__(self, parent, disk_master):
        self.bZCCReady = False 
        self.mainFrame = parent
        self.activeUI = [] # stores all UI controls that can be disabled/enabled
        self.diskMaster = disk_master
        self.zccPath = ""
        self.smallFont = tkFont.Font(family='Helvetica', size='7', weight='bold')
        self.mainFrame.configure(padx=5, pady=5)
        self.mainFrame.columnconfigure(0, minsize=100)
        self.mainFrame.columnconfigure(1, minsize=150)
        self.mainFrame.columnconfigure(2, minsize=0)
        self.createWidgets()
        self.checkZCCConfig()
        self.codeFiles = self.scanSourceCodeFiles()
        self.loadProjectConfig()
        self.populate()
        print("Ready.")

    def createWidgets(self):
        r=0
        # Description
        self.descLabel = Label(self.mainFrame, text="PC-6001 mkII SR build system for z88dk C devkit.")
        self.descLabel.grid(row=r, column=0, columnspan=3, sticky=W+N)
        r+=1
        # Build name
        self.nameLabel = Label(self.mainFrame, text="Build/Binary Name")
        self.nameLabel.grid(row=r, column=0, sticky=W+N)
        self.nameEntry = Entry(self.mainFrame, exportselection=0)
        self.nameEntry.insert(0, "helloworld")
        self.nameEntry.grid(row=r, column=1, columnspan=1, sticky=W+N)
        self.activeUI.append(self.nameEntry)
        r+=1
        # Subtype
        self.subtypeLabel = Label(self.mainFrame, text="PC-6001 Target Mode")
        self.subtypeLabel.grid(row=r, column=0, sticky=W+N)
        self.subtypeList = Listbox(self.mainFrame, selectmode=SINGLE, height=len(SubtypeOptions), exportselection=0)
        self.subtypeList.grid(row=r, column=1, columnspan=2, sticky=W+E)
        for i in SubtypeOptions.itervalues():
            self.subtypeList.insert(END, i)
        self.subtypeList.select_set(0)
        self.activeUI.append(self.subtypeList)
        r+=1
        # Libs
        self.libLabel = Label(self.mainFrame, justify=LEFT, text="Link Libraries\n(only selected are linked)")
        self.libLabel.grid(row=r, column=0, sticky=W+N)
        self.libScroll = Scrollbar(self.mainFrame, orient=VERTICAL)
        self.libScroll.grid(row=r, column=2, sticky=N+S+E)
        self.libList = Listbox(self.mainFrame, selectmode=MULTIPLE, height=4, exportselect=0, yscrollcommand=self.libScroll.set)
        self.libList.grid(row=r, column=1, columnspan=1, sticky=N+S+E+W)
        self.activeUI.append(self.libList)
        for d in StandardLibraries:
            self.libList.insert(END, d)
        r+=1
        self.libScroll['command'] = self.libList.yview
        self.addLibButton = Button(self.mainFrame, text="Add", command=self.btnAddLib, font=self.smallFont, fg='#090')
        self.addLibButton.grid(row=r, column=1, sticky=N+S)
        self.activeUI.append(self.addLibButton)
        self.removeLibButton = Button(self.mainFrame, text="Remove", command=self.btnRemoveLib, font=self.smallFont, fg='red')
        self.removeLibButton.grid(row=r, column=1, columnspan=1, sticky=E+N)
        self.activeUI.append(self.removeLibButton)
        r+=1
        # Code files to compile
        self.codeLabel = Label(self.mainFrame, justify=LEFT, text="Source Code\n(only selected are compiled)")
        self.codeLabel.grid(row=r, column=0, sticky=W+N)
        self.codeScroll = Scrollbar(self.mainFrame, orient=VERTICAL)
        self.codeScroll.grid(row=r, column=2, sticky=N+S+E)
        self.codeList = Listbox(self.mainFrame, selectmode=MULTIPLE, height=4, exportselect=0, yscrollcommand=self.codeScroll.set)
        self.codeList.grid(row=r, column=1, columnspan=1, sticky=N+S+E+W)
        self.activeUI.append(self.codeList)
        self.codeScroll['command'] = self.codeList.yview
        r+=1
        self.refreshCodeButton = Button(self.mainFrame, text="Refresh", command=self.btnRefreshCode, font=self.smallFont, fg='#099')
        self.refreshCodeButton.grid(row=r, column=1, stick=N+W)
        self.activeUI.append(self.refreshCodeButton)
        self.allCodeButton = Button(self.mainFrame, text="All", command=self.btnAllCode, font=self.smallFont, fg='#009')
        self.allCodeButton.grid(row=r, column=1, sticky=N+S)
        self.activeUI.append(self.allCodeButton)
        self.noneCodeButton = Button(self.mainFrame, text="None", command=self.btnNoneCode, font=self.smallFont, fg='#900')
        self.noneCodeButton.grid(row=r, column=1, columnspan=1, sticky=E+N)
        self.activeUI.append(self.noneCodeButton)
        r+=1
        # Output path
        self.outPathLabel = Label(self.mainFrame, text="Output Path")
        self.outPathLabel.grid(row=r, column=0, sticky=W+N)
        self.outPathEntry = Entry(self.mainFrame, exportselection=0)
        self.outPathEntry.grid(row=r, column=1, columnspan=2, sticky=W+E)
        self.outPathEntry.insert(0, BUILD_PATH)
        self.activeUI.append(self.outPathEntry)
        r+=1
        self.outPathBrowseButton = Button(self.mainFrame, text="Browse", command=self.btnBrowseOutputPath, font=self.smallFont, fg='#00d')
        self.outPathBrowseButton.grid(row=r, column=1, columnspan=2, sticky=E+N)
        self.activeUI.append(self.outPathBrowseButton)
        r+=1
        self.canvas = Canvas(self.mainFrame, bg=BAR_DEFAULT, width=100, heigh=8)
        self.canvas.grid(row=r, column=0, columnspan=3, sticky=W+E) 
        r+=1
        # Main button
        self.buildButton = Button(self.mainFrame, text='Save & Build', command=self.btnBuild)
        self.buildButton.grid(row=r, column=0, sticky=W+N)
        self.activeUI.append(self.buildButton)
        self.configButton = Button(self.mainFrame, text='Save', command=self.saveConfig)
        self.configButton.grid(row=r, column=0, sticky=E+N)
        self.activeUI.append(self.configButton)
        self.quitButton = Button(self.mainFrame, text='Quit', command=self.quit)
        self.quitButton.grid(row=r, column=1, columnspan=2, sticky=E+N)
        self.activeUI.append(self.quitButton)

    def quit(self):
        self.mainFrame.destroy()

    def setStateAllChildren(self, desired_state="enable"):
        for child in self.activeUI:
            child["state"] = desired_state

    def updateConfig(self):
        # Update config file based on UI stuff
        # 1. Build name
        ne = self.filterBuildNameEntry()
        assert(len(ne) > 0)
        self.config["compile60"]["buildName"] = ne
        # 2. Target mode
        tm = self.subtypeList.curselection()
        assert(tm != None and len(tm) == 1)
        self.config["compile60"]["mode"] = tm[0]
        # 3. Link libraries
        alibs = self.libList.get(0, END)
        slibs = self.libList.curselection() # returns a tuple of selected
        libs_list = []
        libs_linked = []
        for lib in alibs:
            s = self.filterConfigString(lib)
            assert(s != None and len(s) > 0)
            libs_list.append(s)
        # clear all libs from tasks
        for ts in self.config["tasks"]:
            to_remove = []
            for a in ts["args"]:
                if a[0:2] == "-l":
                    to_remove.append(a)
            for lib in to_remove:
                ts["args"].remove(lib)
        for lnk in slibs:
            s = self.filterConfigString(self.libList.get(lnk))
            assert(s != None and len(s) > 0)
            libs_linked.append(s)
            # add for tasks.json
            for ts in self.config["tasks"]:
                ts["args"].append("-l" + s)
        self.config["compile60"]["libsList"] = libs_list
        self.config["compile60"]["libsLinked"] = libs_linked
        # 4. Source Code
        selected_code = self.codeList.curselection()
        code_files = []
        for sc in selected_code:
            code_files.append(self.codeList.get(sc))
        self.config["compile60"]["codeFiles"] = code_files
        # 5. Output Path
        outp = str(self.outPathEntry.get())
        assert(len(outp) > 0)
        self.config["compile60"]["outputPath"] = outp
        # Refresh code list
        self.resetSourceCodeFilesList(self.scanSourceCodeFiles())

    def saveConfig(self):
        self.updateConfig()
        jdata = json.dumps(self.config, indent=4)
        print("Config data:")
        print(jdata)
        print("Saving config..")
        self.diskMaster.writeTextFile("compile60.json", jdata)
        print("Saving tasks..")
        self.diskMaster.writeTextFile(CONF_PATH + "tasks.json", jdata)
        print("Done.")

    def buildDelayed(self, time = 100):
        self.SetActivityBarColor(BAR_BUSY_3)
        #self.buildButton["state"] = "disabled"
        self.setStateAllChildren("disable")
        self.mainFrame.after(time, self.build)

    def build(self):
        if len(self.codeList.curselection()) == 0:
            print("No Code Selected for Compilation!")
            self.SetActivityBarColor(BAR_BUSY_1)
            self.setStateAllChildren("normal")
            self.codeList.focus = True
            self.codeList.see(0)
            return
        self.SetActivityBarColor(BAR_BUSY_1)
        self.saveConfig()
        if self.bZCCReady == False:
            print("ZCCCFG environment variable is not defined which means ZCC isn't installed correctly. Unable to Build.")
            return
        assert(len(self.zccPath) > 0)
        self.SetActivityBarColor(BAR_BUSY_2)
        print("Building..")
        # Sample: zcc +pc6001 -subtype=32k -ohello.bin hello.c -create-app -lndos -lm
        print("ZCC Path = " + self.zccPath)
        # Prepare params
        # - subtype
        subtype = str(SubtypeIdToOption[self.config["compile60"]["mode"]])
        # - output
        output = self.config["compile60"]["outputPath"] + self.config["compile60"]["buildName"] + ".bin"
        # - prep path
        if self.zccPath[-1] != "\\":
            self.zccPath += "\\"
        # - executable
        build_args = [
            self.zccPath + ZCC_EXE, 
            "+pc6001", 
            "-subtype=" + subtype,
            "-o" + output
        ]
        # - code files
        for c in self.codeList.curselection():
            build_args.append(str(self.codeList.get(c)))
        # - create app
        build_args.append("-create-app")
        # - libraries
        for l in self.libList.curselection():
            build_args.append("-l" + str(self.libList.get(l)))
        print("Build Args = " + str(build_args))
        # Execute build process
        self.SetActivityBarColor(BAR_BUSY_3)
        result = self.runProcess("ZCC Build", build_args)
        self.SetActivityBarColor(BAR_SUCCESS if result == True else BAR_FAIL)
        print("Done.\n")
        #self.buildButton["state"] = "enable"
        self.setStateAllChildren("normal")
    
    # Runs process, assumes build process, returns true or false to indicate success
    def runProcess(self, name, args_list):
        assert(type(args_list) is list and type(name) is str)
        failed = True
        pathProblem = False
        try:
            subprocess.check_call(args_list)
            failed = False
        except OSError as e:
            pathProblem = True
            print(("\n\n{0} Process Failed due to OS Error: ").format(name) + e.strerror)
        except ValueError as e:
            pathProblem = True
            print(("\n\n{0} Process Failed due to invalid Value: ").format(name))
        except subprocess.CalledProcessError as e:
            print(("\n\n{0} Process Failed, process returned code: ").format(name) + str(e.returncode))
        except:
            print(("\n\n{0} Failed, unknown error type").format(name))
        if pathProblem == True:
            tkMessageBox.showwarning("Build Failed", "Most likely this is a path issue. Make sure of the following:\n\n1. Path ""z88dk/lib/config"" is added to a new environment variable named ZCCCFG (this is required by ZCC).\n\n2. add path to z88dk/bin to your PATH variable so ZCC can find all other tools it needs during compilation.")
        return not failed

    def SetActivityBarColor(self, color = '#999', auto_default = False):
        self.canvas["bg"] = color
        if auto_default == True:
            self.mainFrame.after(2000, self.DefaultActivityBarColor)

    def DefaultActivityBarColor(self):
        self.SetActivityBarColor(BAR_DEFAULT)

    # UI events handlers
    def btnAddLib(self):
        # Simple dialog to enter library name
        d = AddLibDialog(self.mainFrame)
        self.mainFrame.wait_window(d.top)
        if len(d.newLibrary) > 0:
            confirm_new = True
            for lib in self.libList.get(0, END):
                if d.newLibrary == lib:
                    print("Library already exists.")
                    confirm_new = False 
            if confirm_new:
                self.libList.insert(END, d.newLibrary)

    def btnRemoveLib(self):
        if len(self.libList.curselection()) == 0:
            return
        wmsg = "Are you sure you want to remove these libraries?\n"
        for i in self.libList.curselection():
            wmsg += self.libList.get(i) + " "
        result = tkMessageBox.askokcancel("Confirm Removal", wmsg, icon=tkMessageBox.WARNING)
        if result:
            print("Removing libraries from list..")
            to_remove = []
            all_libs = self.libList.get(0, END)
            for i in self.libList.curselection():
                to_remove.append(self.libList.get(i))
            i = 0
            for lib in all_libs:
                if lib in to_remove:
                    self.libList.delete(i)
                else:
                    i += 1
            print("Done.")

    def btnRefreshCode(self):
        self.resetSourceCodeFilesList(self.scanSourceCodeFiles())

    def btnAllCode(self):
        self.scanSourceCodeFiles()
        self.codeList.selection_set(0, self.codeList.size())

    def btnNoneCode(self):
        self.scanSourceCodeFiles()
        self.codeList.selection_clear(0, self.codeList.size())

    def btnBrowseOutputPath(self):
        out_path = tkFileDialog.askdirectory()
        if out_path == "":
            out_path = "./build/"
        if out_path[-1:] != "/":
            out_path = out_path + '/'
        self.outPathEntry.delete(0, len(self.outPathEntry.get()))
        self.outPathEntry.insert(0, out_path)

    def btnBuild(self):
        self.buildDelayed()

    # Checks for environment variable named ZCCCFG which is required by ZCC compiler
    def checkZCCConfig(self):
        try:
            zcc = str(os.environ[ZCC_CONFIG_VAR])
            if len(zcc) > 0:
                self.zccPath = zcc[0:zcc.index("lib\\config")] + "bin\\"
                self.bZCCReady = True
        except:
            self.buildButton['state'] = 'disabled'
            tkMessageBox.showwarning("z88dk path not configured", "ZCCCFG environment variable not found\n\nZCCCFG should be set manually to point to the lib/conf folder under z88dk as that's used for zcc to work.\nAdditionally, add path to z88dk/bin folder to your environment variables so ZCC compiler can find any other tools it needs.")
            self.bZCCReady = False

    # Checks NameEntry text and filters it to only include alpha-numeric letters
    def filterBuildNameEntry(self):
        current = str(self.nameEntry.get())
        if len(current) == 0:
            current = "helloworld"
        filtered = ""
        for c in current:
            if c.isalnum() == True:
                filtered += c
        self.nameEntry.delete(0, len(current))
        self.nameEntry.insert(0, filtered)
        return filtered

    # Filters given strings to remove non alphanumeric characters
    def filterConfigString(self, unfiltered_string):
        filtered = ""
        for c in unfiltered_string:
            if c.isalnum() == True:
                filtered += c
        return filtered

    # Loads the compile60.json file if found or creates new one from template if not
    def loadProjectConfig(self):
        cfg = self.diskMaster.readTextFile("compile60.json")
        if cfg == "":
            # Generate default
            toout = str.format(COMPILE_TEMPLATE, 
                buildName="hello", 
                buildMode="2", 
                listOfLibraries='"ndos","m"', 
                linkLibraries="", 
                outputPath="./build/",
                codeFiles=json.dumps(list(self.codeList.get(0, self.codeList.size() - 1))),
                libraries0="",
                libraries1="",
                libraries2="",
                libraries3=""
            )
            self.diskMaster.writeTextFile("compile60.json", toout)
            cfg = self.diskMaster.readTextFile("compile60.json")
        if cfg == "":
            raise RuntimeError("Could not load compile60.json or create a new one (read-only?)")
        self.config = json.loads(cfg)

    # Scans the project folder (non-recursive) for .C files and returns a list of file names
    def scanSourceCodeFiles(self):
        files = self.diskMaster.enumRootFilesWithExtension(".", "c")
        cfiles = []
        print("Refresh code files: ")
        for f in files:
            if str(f)[-2:] == ".c":
                print("    " + str(f))
                cfiles.append(f)
        return cfiles

    # Will clear and set source code files list to given and apply previous selection
    def resetSourceCodeFilesList(self, code_files):
        # Store selected code files
        selected_code_files = []
        for sc in self.codeList.curselection():
            selected_code_files.append(self.codeList.get(sc))
        # Clear code list
        self.codeList.delete(0, END)
        # Repopulate code list
        for cf in code_files:
            self.codeList.insert(END, cf)
        # Reapply selected code files 
        for scf in selected_code_files:
            try:
                idx = code_files.index(scf)
            except:
                continue
            self.codeList.selection_set(idx)

    # Populates all widgets of the app based on the collected data
    def populate(self):
        # Build name
        self.nameEntry.delete(0, len(self.nameEntry.get()))
        self.nameEntry.insert(0, self.config["compile60"]["buildName"])
        # Target mode
        self.subtypeList.selection_clear(0, self.subtypeList.size())
        self.subtypeList.selection_set(self.config["compile60"]["mode"])
        # Link libraries
        # - Libs list
        libs_lst = self.config["compile60"]["libsList"]
        linked_lst = self.config["compile60"]["libsLinked"]
        self.libList.delete(0, self.libList.size())
        for lib in libs_lst:
            self.libList.insert(END, lib)
        # - Libs linked
        for lib in linked_lst:
            idx = libs_lst.index(lib)
            self.libList.selection_set(idx)
        # - Code files: this assumes code files have been refreshed recently
        scode_lst = self.config["compile60"]["codeFiles"]
        for cf in self.codeFiles:
            self.codeList.insert(END, cf)
        checked_code_lst = []
        for sf in scode_lst:
            if sf in self.codeFiles:
                checked_code_lst.append(sf)
        for sf in checked_code_lst:
            idx = self.codeFiles.index(sf)
            self.codeList.selection_set(idx)
        # Output path
        outp = self.config["compile60"]["outputPath"]
        self.outPathEntry.delete(0, END)
        self.outPathEntry.insert(0, outp)   

class AddLibDialog:
    def __init__(self, parent):
        self.newLibrary = ""
        self.top = Toplevel(parent)
        self.top.transient(parent)
        self.top.grab_set()
        self.top.title("Add Library")
        Label(self.top, text="Add new library to list, just use the library file name with no extension:").pack()
        self.top.bind("<Return>", self.ok)
        self.e = Entry(self.top, text="")
        self.e.bind("<Return>", self.ok)
        self.e.bind("<Escape>", self.cancel)
        self.e.pack(padx=15)
        self.e.focus_set()
        b = Button(self.top, text="OK", command=self.ok)
        b.pack(pady=5)
    
    def ok(self, event=None):
        print("Adding new library: " + self.e.get())
        self.newLibrary = self.e.get()
        self.top.destroy()

    def cancel(self, event=None):
        self.top.destroy()

## Performs booting operations (pre-Tk startup)
## Performs all necessary I/O operations.
class DiskMaster:
    def __init__(self):
        print("Starting compile60..")

    def downloadFile(self, url_file, output_file):
        # Downloads a file to memory then writes it to a output_file
        incoming = urllib2.urlopen(url_file)
        with open(output_file, 'wb') as output:
            output.write(incoming.read())

    def boot(self):
        # Check for .vscode folder
        if os.path.isdir(CONF_PATH) == False:
            print("Creating .vscode folder..")
            os.mkdir(CONF_PATH)
        # Check for build folder
        if os.path.isdir(BUILD_PATH) == False:
            print("Creating build folder..")
            os.mkdir(BUILD_PATH)
        # Check for p6.ico
        if os.path.isfile(CONF_PATH + "p6.ico") == False:
            print("Downloading app icon..")
            self.downloadFile("http://zenithsal.com/assets/pc6002/p6.ico", CONF_PATH + "p6.ico")

    # Walks given search path searching for file with given extension, returns list of files found
    def enumRootFilesWithExtension(self, search_path, extension):
        out = []
        for root, dirs, files in os.walk(search_path):
            for f in files:
                if str(f)[-(len(extension) + 1):] == '.' + extension:
                    out.append(f)
            break
        return out

    # Opens and reads an entire text file, returns empty string if file not found
    def readTextFile(self, filename):
        f = self.openFileForRead(filename)
        if f:
            data = str(f.read())
            self.closeFile(f)
            return data
        else:
            return ""

    # Writes given text data to specified file, returns True to indicate success, False otherwise
    def writeTextFile(self, filename, data):
        assert(type(data) is str and len(data) > 0)
        if not os.path.exists(filename) or os.path.isfile(filename):
            with open(filename, 'w') as file_handle:
                file_handle.write(data)
                file_handle.flush()
            return True
        else:
            return False

    def openFileForRead(self, filename):
        if os.path.isfile(filename):
            return open(filename, 'r')
        else:
            return None

    def closeFile(self, file_handle):
        assert(type(file_handle) is file)
        if file_handle.closed == False: 
            file_handle.close()

diskm = DiskMaster()
diskm.boot()
root = Tk()
root.title("COMPILE60")
root.iconbitmap(default='.vscode/p6.ico')
myapp = Application(root, diskm)
root.mainloop()
