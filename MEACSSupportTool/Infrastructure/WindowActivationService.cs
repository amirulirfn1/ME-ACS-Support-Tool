using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;

namespace MEACSSupportTool.Infrastructure;

public static class WindowActivationService
{
    private const int SwRestore = 9;

    public static void BringToFront(Window? window)
    {
        if (window == null)
            return;

        window.Dispatcher.Invoke(() =>
        {
            if (window.WindowState == WindowState.Minimized)
                window.WindowState = WindowState.Normal;

            if (!window.IsVisible)
                window.Show();

            window.ShowActivated = true;
            window.Activate();

            var handle = new WindowInteropHelper(window).Handle;
            if (handle != IntPtr.Zero)
            {
                ShowWindowAsync(handle, SwRestore);
                SetForegroundWindow(handle);
            }

            window.Topmost = true;
            window.Topmost = false;
            window.Focus();
        });
    }

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
}
