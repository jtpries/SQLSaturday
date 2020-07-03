using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemGuide
    {
		[System.Xml.Serialization.XmlElement("name")]
		public string name { get; set; }

		[System.Xml.Serialization.XmlElement("startDate")]
		public string startDate { get; set; }

		[System.Xml.Serialization.XmlElement("attendeeEstimate")]
		public string attendeeEstimate { get; set; }

		[System.Xml.Serialization.XmlElement("timezone")]
		public string timezone { get; set; }

		[System.Xml.Serialization.XmlElement("description")]
		public string description { get; set; }

		[System.Xml.Serialization.XmlElement("twitterHashtag")]
		public string twitterHashtag { get; set; }

		[System.Xml.Serialization.XmlElement("venue")]
		public SQLSaturdayItemGuideVenue venue { get; set; }
    }
}
