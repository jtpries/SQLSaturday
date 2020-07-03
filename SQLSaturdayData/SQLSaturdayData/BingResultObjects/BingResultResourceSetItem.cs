using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.Serialization;

namespace SQLSaturdayData
{
    class BingResultResourceSetItem
    {
        public string type { get; set; }
        public List<double> bbox { get; set; }
        public string name { get; set; }
        public BingResultResourceSetPoint point { get; set; } 
        public BingResultResourceSetAddress address { get; set; } 
        public string confidence { get; set; }
        public string entityType { get; set; }
        public string BingResultResourceSetGeocodePoint { get; set; }
        public List<string> matchCodes { get; set; }
    }
}
