using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemSessionSpeakers
    {
		[System.Xml.Serialization.XmlElement("speaker")]
		public List<SQLSaturdayItemSessionSpeaker> speaker { get; set; }
    }
}
