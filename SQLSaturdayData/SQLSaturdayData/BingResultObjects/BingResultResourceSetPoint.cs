using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.Serialization;

namespace SQLSaturdayData
{
    class BingResultResourceSetPoint
    {
        public string type { get; set; }
        public List<double> coordinates { get; set; }
    }
}
