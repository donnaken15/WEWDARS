
using NtApiDotNet;
using System;
using System.Diagnostics;

// PORT THIS TO C!!!!!!!!!!!!!!
class Program
{
	static int Main(string[] args)
	{
		if (args.Length != 1)
			return 1;
		bool enabled = false, get = false;
		{
			byte e = Convert.ToByte(args[0]);
			switch (e)
			{
				case 0:
					break;
				case 1:
					enabled = true;
					break;
				case 5:
					get = true;
					break;
				default:
					Console.WriteLine("Invalid option");
					return 1; 
			}
		}
		NtObject g = NtObject.OpenWithType(
			"Section", "\\Sessions\\" +
				Process.GetCurrentProcess().SessionId +
				"\\Windows\\ThemeSection", null,
			GenericAccessRights.WriteDac |
			GenericAccessRights.ReadControl);
		string sec = "O:BAG:SYD:(A;;" +
				(enabled ? "" : "CCLC") +
			"RC;;;IU)(A;;" +
				(enabled ? "" : "CC") +
			"D" +
				(enabled ? "" : "CL") + "CSWRPSDRCWDWO;;;SY)";
		if (!get)
			g.SetSecurityDescriptor(new SecurityDescriptor(sec),
				SecurityInformation.Dacl);
		// getting 0xC0000058 when using C
		else
		{
			int a = (sec == g.Sddl.ToString() ? 0 : 1);
			g.Close();
			return a;
		}
		g.Close();
		return 0;
	}
}
