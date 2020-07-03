using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.Serialization;

namespace SQLSaturdayData
{
    [DataContract]
    class BingResult
    {
        [DataMember]
        public string authenticationResultCode { get; set; }
        public string brandLogoUri { get; set; }
        public string copyright { get; set; }
        public List<BingResultResourceSet> resourceSets { get; set; }
        public string statusCode { get; set; }
        public string statusDescription { get; set; }
        public string traceId { get; set; }
    }
}
