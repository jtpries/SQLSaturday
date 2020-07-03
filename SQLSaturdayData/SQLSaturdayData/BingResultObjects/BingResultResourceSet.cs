using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.Serialization;

namespace SQLSaturdayData
{
    class BingResultResourceSet
    {
        public string estimatedTotal { get; set; }
        public List<BingResultResourceSetItem> resources { get; set; }
    }
}
