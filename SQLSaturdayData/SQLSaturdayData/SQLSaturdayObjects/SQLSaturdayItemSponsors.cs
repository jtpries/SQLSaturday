using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemSponsors
    {
		[System.Xml.Serialization.XmlElement("sponsor")]
		public List<SQLSaturdayItemSponsor> sponsor { get; set; }
    }
}
