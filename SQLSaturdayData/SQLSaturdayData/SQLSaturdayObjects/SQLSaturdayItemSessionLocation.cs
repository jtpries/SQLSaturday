using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemSessionLocation
    {
		[System.Xml.Serialization.XmlElement("name")]
		public string name { get; set; }
    }
}
