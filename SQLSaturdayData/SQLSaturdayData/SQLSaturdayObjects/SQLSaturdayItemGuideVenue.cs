using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemGuideVenue
    {
		[System.Xml.Serialization.XmlElement("name")]
		public string name { get; set; }

		[System.Xml.Serialization.XmlElement("street")]
		public string street { get; set; }

		[System.Xml.Serialization.XmlElement("city")]
		public string city { get; set; }

		[System.Xml.Serialization.XmlElement("state")]
		public string state { get; set; }

		[System.Xml.Serialization.XmlElement("zipcode")]
		public string zipcode { get; set; }
    }
}
