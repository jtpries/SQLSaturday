using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemSession
    {
		[System.Xml.Serialization.XmlElement("importID")]
		public string importID { get; set; }

		[System.Xml.Serialization.XmlElement("speakers")]
		public SQLSaturdayItemSessionSpeakers speakers { get; set; }

		[System.Xml.Serialization.XmlElement("track")]
		public string track { get; set; }

		[System.Xml.Serialization.XmlElement("location")]
		public SQLSaturdayItemSessionLocation location { get; set; }

		[System.Xml.Serialization.XmlElement("title")]
		public string title { get; set; }

		[System.Xml.Serialization.XmlElement("description")]
		public string description { get; set; }

		[System.Xml.Serialization.XmlElement("startTime")]
		public string startTime { get; set; }

		[System.Xml.Serialization.XmlElement("endTime")]
		public string endTime { get; set; }
    }
}
