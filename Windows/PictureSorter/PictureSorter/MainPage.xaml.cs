using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.Storage;
using Windows.Storage.FileProperties;
using Windows.Storage.Pickers;
using Windows.Storage.Search;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Imaging;
using Windows.UI.Xaml.Navigation;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace PictureSorter
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private IList<StorageFile> _files;
        private StorageFolder _folder;
        private StorageFolder _folderOne;
        private StorageFolder _folderTwo;
        private StorageFolder _folderThree;
        private StorageFolder _folderFour;

        public MainPage()
        {
            this.InitializeComponent();
            Window.Current.CoreWindow.KeyDown += CoreWindow_KeyDown;
        }

        private async void ButtonSelectFolder_Click(object sender, RoutedEventArgs e)
        {
            var folderPicker = new FolderPicker()
            {
                SuggestedStartLocation = PickerLocationId.Desktop
            };
            foreach (var extension in FileExtensions.Image)
            {
                folderPicker.FileTypeFilter.Add(extension);
            }

            var _folder = await folderPicker.PickSingleFolderAsync();
            if (_folder == null)
            {
                Debug.WriteLine("No folder picked!");
                return;
            }

            var queryOptions = new QueryOptions(CommonFileQuery.OrderByName, FileExtensions.Image)
            {
                FolderDepth = FolderDepth.Shallow
            };
            var query = _folder.CreateFileQueryWithOptions(queryOptions);
            var files = await query.GetFilesAsync();
            _files = new List<StorageFile>(files);

            var createOptions = CreationCollisionOption.OpenIfExists;

            _folderOne = await _folder.CreateFolderAsync("1", createOptions);
            _folderTwo = await _folder.CreateFolderAsync("2", createOptions);
            _folderThree = await _folder.CreateFolderAsync("3", createOptions);
            _folderFour = await _folder.CreateFolderAsync("4", createOptions);

            ShowFile();
        }

        private async void ShowFile()
        {
            if (_files.Count == 0)
            {
                Debug.WriteLine("No more files to show!");
                return;
            }
            StorageFile file = _files[0];
            if (file == null)
            {
                Debug.WriteLine("Null file.... wat?");
                AdvanceFile();
                return;
            }

            var size = (uint)(((Frame)Window.Current.Content).ActualWidth / 2); //Send your required size
            using (StorageItemThumbnail thumbnail = await file.GetScaledImageAsThumbnailAsync(ThumbnailMode.SingleItem, size, ThumbnailOptions.ResizeThumbnail))
            {
                if (thumbnail == null)
                {
                    Debug.WriteLine("I can't make a thumbnail because fuck you, that's why.");
                    AdvanceFile();
                    return;
                }
                //Prepare thumbnail to display
                BitmapImage bitmapImage = new BitmapImage();

                bitmapImage.SetSource(thumbnail);
                imageThumbnail.Source = bitmapImage;
            }
        }

        private void AdvanceFile()
        {
            _files.RemoveAt(0);
            ShowFile();
        }

        private async void CoreWindow_KeyDown(Windows.UI.Core.CoreWindow sender, Windows.UI.Core.KeyEventArgs e)
        {
            if (_files.Count == 0)
            {
                Debug.WriteLine("No more files to show!");
                return;
            }
            switch (e.VirtualKey)
            {
                case Windows.System.VirtualKey.Number1:
                    await MoveTo(_folderOne);
                    break;
                case Windows.System.VirtualKey.Number2:
                    await MoveTo(_folderTwo);
                    break;
                case Windows.System.VirtualKey.Number3:
                    await MoveTo(_folderThree);
                    break;
                case Windows.System.VirtualKey.Number4:
                    await MoveTo(_folderFour);
                    break;
                default:
                    return;
            }
            AdvanceFile();
        }

        private async Task MoveTo(StorageFolder folder)
        {
            var file = _files[0];
            await file.MoveAsync(folder);
        }
    }
}
