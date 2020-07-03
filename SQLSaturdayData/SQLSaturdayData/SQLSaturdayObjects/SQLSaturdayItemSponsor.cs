using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemSponsor
    {
		[System.Xml.Serialization.XmlElement("importID")]
		public string importID { get; set; }

		[System.Xml.Serialization.XmlElement("name")]
		public string name { get; set; }

		[System.Xml.Serialization.XmlElement("label")]
		public string label { get; set; }

		[System.Xml.Serialization.XmlElement("url")]
		public string url { get; set; }

		[System.Xml.Serialization.XmlElement("imageURL")]
		public string imageURL { get; set; }

		[System.Xml.Serialization.XmlElement("imageHeight")]
		public string imageHeight { get; set; }

		[System.Xml.Serialization.XmlElement("imageWidth")]
		public string imageWidth { get; set; }
    }
}
