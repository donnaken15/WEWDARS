using System;
using System.IO;
using System.Diagnostics;
using System.Security.AccessControl;
using System.Security.Permissions;
using System.Security.Principal;
using System.Threading;
using System.Runtime.InteropServices;

class Program
{
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr LoadLibraryEx(string lib, IntPtr hfile, uint flags);
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr FreeLibrary(IntPtr hfile);
    [DllImport("kernel32.dll")]
    private static extern IntPtr FindResource(IntPtr hfile, string name, string type);
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr LoadResource(IntPtr hfile, IntPtr hResInfo);
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr SizeofResource(IntPtr hfile, IntPtr hResInfo);
    [DllImport("kernel32.dll", CallingConvention = CallingConvention.StdCall,
        CharSet = CharSet.Unicode, EntryPoint = "BeginUpdateResourceW",
        ExactSpelling = true, SetLastError = true)]
    public static extern IntPtr BeginUpdateResource(string fname, bool deleteres);
    [DllImport("kernel32.dll", CallingConvention = CallingConvention.StdCall,
        CharSet = CharSet.Unicode, EntryPoint = "UpdateResourceW",
        ExactSpelling = true, SetLastError = true)]
    public static extern bool UpdateResource(IntPtr hupdate,
        string type, string name, ushort lang, byte[] data, uint cb);
    [DllImport("kernel32.dll", CallingConvention = CallingConvention.StdCall,
        CharSet = CharSet.Unicode, EntryPoint = "EndUpdateResourceW",
        ExactSpelling = true, SetLastError = true)]
    public static extern bool EndUpdateResource(IntPtr hupdate, bool discard);

    static bool isImage(string fname)
    {
        uint m;
        {
            Stream fs = File.OpenRead(fname);
            BinaryReader magiccheck = new BinaryReader(fs);
            m = magiccheck.ReadUInt32();
            magiccheck.Close();
            fs.Close();
        }
        return m == 0x00905A4D;
    }
    public static string NP(string path)
    {
        return Path.GetFullPath(new Uri(path).LocalPath)
                .TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
                .ToUpperInvariant();
    }
    static int Main(string[] args)
    {
        if (args.Length != 1)
            return 2;
        bool disabled = false, get = false;
        {
            byte e = Convert.ToByte(args[0]);
            switch (e)
            {
                case 0:
                    break;
                case 1:
                    disabled = true;
                    break;
                case 5:
                    get = true;
                    break;
                default:
                    Console.WriteLine("Invalid option");
                    return 1;
            }
        }
        string WINDIR = Environment.GetEnvironmentVariable("WINDIR");
        string SxS = WINDIR + "\\WinSxS";
        DirectoryInfo di = new DirectoryInfo(SxS);
        // sample path:
        // C:\Windows\WinSxS\amd64_microsoft-windows-explorerframe_^
        //		31bf3856ad364e35_10.0.19041.964_none_a05eb78fd2b22b21\
        //		ExplorerFrame.dll.mun
        // don't know if first hash is consistent but it's present
        // on thousands of other directories as well
        bool gotmun = false;
        string mun = "ExplorerFrame.dll.mun";
        string mpath = null;
        Console.Write("Finding unmodified "+mun+"...");
        Console.Error.WriteLine();
        foreach (DirectoryInfo d in di.GetDirectories(
            "amd64_microsoft-windows-explorerframe_31bf3856ad364e35_10.0.*_none_*",
            SearchOption.TopDirectoryOnly)) {
            Console.Error.WriteLine(d.Name);
            if (File.Exists(d.FullName+'\\'+mun)) {
                mpath = d.FullName + '\\' + mun;
                {
                    if (isImage(mpath))
                    {
                        Console.WriteLine("Got");
                        gotmun = true;
                    }
                }
                break;
            }
        }
        if (!gotmun)
        {
            Console.Write("Can't find file by normal search, trying all available directories...");
            Console.Error.WriteLine();
            foreach (FileInfo d in di.GetFiles(mun, SearchOption.AllDirectories))
            {
                Console.Error.WriteLine(d.FullName);
                mpath = d.FullName;
                if (isImage(mpath))
                {
                    Console.WriteLine("Got");
                    gotmun = true;
                }
                gotmun = true;
                break;
            }
        }
        if (!gotmun)
        {
            Console.WriteLine("Failed");
            return 1;
        }
        string SysRes = WINDIR + "\\SystemResources\\";
        string frame = SysRes + mun;
        if (!get)
        {
            // figure out how to edit the file without killing explorer like RibbonDisabler
            foreach (Process p in Process.GetProcessesByName("explorer"))
                //TODO?: restore explorer windows somehow
            {
                if (NP(p.MainModule.FileName) == NP(WINDIR + "\\explorer.exe"))
                {
                    p.Kill();
                    p.WaitForExit();
                }
            }
            Console.WriteLine("Setting permissions");
            Type NTAcc = typeof(NTAccount);
            IdentityReference CLU = WindowsIdentity.GetCurrent().User.Translate(NTAcc);
            IdentityReference owner = null;
            FileSecurity fs = File.GetAccessControl(frame);
            FileSystemRights fsr_old = FileSystemRights.Read;
            foreach (FileSystemAccessRule ace in fs.GetAccessRules(true, true, NTAcc))
            {
                if (ace.IdentityReference.Value.EndsWith(CLU.Value))
                {
                    Console.WriteLine(CLU.Value);
                    fsr_old = ace.FileSystemRights;
                }
            }
            FileSystemAccessRule fsar = new FileSystemAccessRule(
                CLU, fsr_old | FileSystemRights.Modify, AccessControlType.Allow
            );
            fs.AddAccessRule(fsar);
            owner = fs.GetOwner(NTAcc);
            fs.SetOwner(CLU);
            File.SetAccessControl(frame, fs);

            Console.WriteLine("Copying frame");
            // SOMEHOW ONLY RUNNING FROM VISUAL STUDIO AND NOT COMMAND LINE
            //File.Copy(frame, frame+".bak", true);
            File.Copy(mpath, frame, true);
            if (disabled)
            {
                // reveng'd RibbonDisabler with dnSpy
                // stupid obfusctaed POS
                //IntPtr DLL = LoadLibraryEx(frame, IntPtr.Zero, 2);
                //IntPtr ribbon = FindResource(DLL, "EXPLORER_RIBBON", "UIFILE");
                //FreeLibrary(DLL);
                Console.WriteLine("Severing ribbon");
                IntPtr editor = BeginUpdateResource(frame, false);
                EndUpdateResource(editor, false);
                //if (!EndUpdateResource(editor,
                //	!UpdateResource(editor, "UIFILE", "EXPLORER_RIBBON", 1033, null, 0)))
                {
                    Console.WriteLine("Failed ("+Marshal.GetLastWin32Error()+")");
                }
            }

            fsar = new FileSystemAccessRule(
                CLU, fsr_old, AccessControlType.Allow);
            fs.SetAccessRule(fsar);
            fs.SetOwner(owner);

            File.SetAccessControl(frame, fs);
            //Console.WriteLine(fs.GetOwner(NTAcc));
            //Console.WriteLine(WindowsIdentity.GetCurrent().Name);
            //File.Copy(mpath, frame, true);
            Console.WriteLine("Done");
        }
        else
        {
            IntPtr DLL = LoadLibraryEx(frame, IntPtr.Zero, 2);
            IntPtr ribbon = FindResource(DLL, "EXPLORER_RIBBON", "UIFILE");
            FreeLibrary(DLL);
            return (ribbon == IntPtr.Zero) ? 1 : 0;
        }
        return 0;
    }
}
