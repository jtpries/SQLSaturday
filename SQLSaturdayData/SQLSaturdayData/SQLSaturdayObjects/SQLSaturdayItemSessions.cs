using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemSessions
    {
		[System.Xml.Serialization.XmlElement("event")]
		public List<SQLSaturdayItemSession> session { get; set; }
    }
}
