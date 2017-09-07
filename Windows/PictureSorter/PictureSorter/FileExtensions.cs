using System.Collections.Generic;

namespace PictureSorter
{
    internal class FileExtensions
    {
        public static readonly IList<string> Image = new List<string> 
        {
            ".jpg", ".png", ".bmp", ".gif", ".tif"
        };
    }
}
