using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	[System.Xml.Serialization.XmlRoot("GuidebookXML")]
	public class SQLSaturdayItem
    {
		[System.Xml.Serialization.XmlElement("guide")]
		public SQLSaturdayItemGuide guide { get; set; }

		[System.Xml.Serialization.XmlElement("sponsors")]
		public SQLSaturdayItemSponsors sponsors { get; set; }

		[System.Xml.Serialization.XmlElement("speakers")]
		public SQLSaturdayItemSpeakers speakers { get; set; }

		[System.Xml.Serialization.XmlElement("events")]
		public SQLSaturdayItemSessions sessions { get; set; }
    }
}
