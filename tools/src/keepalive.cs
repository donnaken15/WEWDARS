
using System;
using System.Diagnostics;
using System.Windows.Forms;

class _
{
	public static void Main(string[] a)
	{
		if (a.Length == 0)
		{
			//MessageBox.Show("keepalive [program] [arguments]+\n\n"+
			//	"Make sure a program always stays open when\n"+
			//	"there are attempts to close or kill it.", "Usage",
			//	MessageBoxButtons.OK,
			//	MessageBoxIcon.Information);
			return;
		}
		//try {
			Process p = new Process();
			{
				ProcessStartInfo psi = new ProcessStartInfo(a[0], a.Length > 1 ? string.Join(" ",a,1,a.Length-1) : "");
				psi.UseShellExecute = true;
				p.StartInfo = psi;
				while (true)
				{
					p.Start();
					p.WaitForExit();
				}
			}
		//} catch (Exception e) {
			//MessageBox.Show(e.ToString(), "ERROR!!111",
			//	MessageBoxButtons.OK,
			//	MessageBoxIcon.Error);
		//}
	}
}


