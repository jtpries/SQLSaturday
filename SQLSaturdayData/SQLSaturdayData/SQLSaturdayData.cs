///===================================================================================
///   SQLSaturdayData.cs
///===================================================================================
/// -- Author:       Jeff Pries (jeff@jpries.com)
/// -- Create date:  1/14/2019
/// -- Description:  Main driver class for SQLSaturdayData application

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Net;
using System.Net.Http;
using System.Xml.Serialization;
using System.Web.Script.Serialization;

namespace SQLSaturdayData
{
    class SQLSaturdayData
    {
        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// Global Constants and Variables
        /// 

        // Constants
        const string VERSION = "1.0";
        const string BASEURL = "http://www.sqlsaturday.com/eventxml.aspx?sat={0}";
        const string BASESUBMITTEDURL = "http://www.sqlsaturday.com/{0}/Sessions/SubmittedSessions.aspx";
        const string BASEOUTPUTFILENAME = "sqlsaturday_{0}.xml";
        const string BASESUBMITTEDOUTPUTFILENAME = "sqlsaturdaysubmitted_{0}.html";
        const int MAXNUMEVENTS = 999999;
        const string BINGGEOURL = "http://dev.virtualearth.net/REST/v1/Locations?countryRegion={country}&adminDistrict={state}&locality={city}&postalCode={postalCode}&addressLine={addressLine}&key={apikey}";
        //const string BASEGEOFILENAME = "geocoderesult_{0}.json";

        const string DBTABLEEVENT = "tmp.SQLSaturdayEvent";
		const string DBTABLESPONSOR = "tmp.SQLSaturdaySponsor";
		const string DBTABLESPEAKER = "tmp.SQLSaturdaySpeaker";
		const string DBTABLESESSION = "tmp.SQLSaturdaySession";
		const string DBTABLESESSIONSPEAKER = "tmp.SQLSaturdaySessionSpeaker";
        const string DBTABLESUBMITTED = "tmp.SQLSaturdayEventSubmitted";
        const string DBQUERYSTAGESUBMITTED = "etl.usp_StageSQLSaturdayEventSubmitted";
        const string DBQUERYSTAGEALL = "etl.usp_StageAllData";
        const string DBQUERYLOADALL = "etl.usp_LoadAllData";

        // Variables
        string dataDir;
        string cacheDir;

		string destDBConnString;
        SqlConnectionStringBuilder destDBCSB;
        string connString;

        HttpClient client;
        string httpHeadUserAgent = "";
        string bingAPIKey;

        // Params
        bool isOffline = false;                        // Offline Debug mode enabled (usually false)
        bool isFull = false;
		bool isClear = false;
		bool isScan = false;
		bool isParse = false;
		bool isDelete = true;
        bool isSubmitted = true;
        bool isSetStart = false;
        bool isSetNum = false;
        bool isStop = false;
        bool isGeolocate = false;
        int startEvent;
        int numEvents;


        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// Default Class constructor
        ///  

        public SQLSaturdayData()
        {
            dataDir = Directory.GetCurrentDirectory();
            cacheDir = dataDir + "\\cache";

            ReadSettings();

            PerformWelcome();

            client = new HttpClient();
            client.DefaultRequestHeaders.UserAgent.ParseAdd(httpHeadUserAgent);
            client.DefaultRequestHeaders.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8");
            client.DefaultRequestHeaders.Add("AcceptLanguage", "en-US,en;q=0.9");

        }


        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// ReadSettings Method
        /// 

        public void ReadSettings()
        {

            // Read DB connection string - DestDB
            var destDBConnStringObj = ConfigurationManager.ConnectionStrings["DestDB"];
            if (destDBConnStringObj != null)
            {
                destDBConnString = destDBConnStringObj.ConnectionString;
                destDBCSB = new SqlConnectionStringBuilder(destDBConnString);
            }

            if (destDBCSB != null)
            {
                connString = destDBCSB.ConnectionString;
            }

            // Read the App Settings
            httpHeadUserAgent = ConfigurationManager.AppSettings["HttpUserAgentString"];
            bingAPIKey = ConfigurationManager.AppSettings["BingMapsAPIKey"];
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// PerformWelcome Method
        ///   

        public void PerformWelcome()
        {
            Console.WriteLine("");
            Console.WriteLine("");
            Console.WriteLine("================================================================");
            Console.WriteLine("||                   SQLSaturdayData v" + VERSION + "                     ||");
            Console.WriteLine("||              by Jeff Pries (jeff@jpries.com)               ||");
            Console.WriteLine("================================================================");
            Console.WriteLine("");
            Console.WriteLine("");
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// ParseArgs Method
        /// 

        public void ParseArgs(string[] args)
        {
            // Default
            isFull = false;
            isClear = false;
            isDelete = true;
            isScan = true;
            isParse = true;
            isSubmitted = true;
            isSetStart = false;
            isSetNum = false;
            isStop = false;
            isGeolocate = true;
            startEvent = 1;
            numEvents = MAXNUMEVENTS;

            // Check for args, if none, set default settings
            if (args.Length == 0)
            {
                Console.WriteLine("No arguments specified, running in default incremental mode.  Run with /help to see available options.");

                isFull = false;
                isClear = false;
                isDelete = true;
                isScan = true;
                isParse = true;
                isSubmitted = true;
                isSetStart = false;
                isSetNum = false;
                isGeolocate = true;
            }
            else
            {
                // Search the args array and set the option flags accordingly
                foreach (string arg in args)
                {
                    string argStr = arg.ToLower();

                    if (argStr == "/?" || argStr == "/help")
                    {
                        Console.WriteLine("Options:");
                        Console.WriteLine("     /start=X");
                        Console.WriteLine("     /num=X");
                        Console.WriteLine("     /full");
                        Console.WriteLine("     /clear");
                        Console.WriteLine("     /nodelete");
                        Console.WriteLine("     /noscan");
                        Console.WriteLine("     /noparse");
                        Console.WriteLine("     /nosubmitted");
                        Console.WriteLine("     /nogeolocate");
                        Console.WriteLine("     /offline");

                        isStop = true;
                        break;
                    }
                    else if (argStr == "/full")
                    {
                        isClear = true;
                        isFull = true;
                    }
                    else if (argStr == "/noscan")
                    {
                        isScan = false;
                    }
                    else if (argStr == "/noparse")
                    {
                        isParse = false;
                    }
                    else if (argStr == "/nosubmitted")
                    {
                        isSubmitted = false;
                    }
                    else if (argStr == "/nodelete")
                    {
                        isDelete = false;
                    }
                    else if (argStr == "/nogeolocate" || argStr == "/nogeo")
                    {
                        isGeolocate = false;
                    }
                    else if (argStr == "/clear" || argStr == "/clean")
                    {
                        isClear = true;
                        isScan = false;
                        isParse = false;
                        isSubmitted = false;

                        break;
                    }
                    else if (argStr == "/offline")
                    {
                        isOffline = true;
                    }
                    else if (argStr.Length > 5)
                    {
                        if (argStr.Substring(0, 5) == "/num=")
                        {
                            string numTemp = argStr.Substring(5, argStr.Length - 5);
                            Int32.TryParse(numTemp, out numEvents);
                            isSetNum = true;
                        }
                        else
                        {
                            if (argStr.Length > 7)
                            {
                                if (argStr.Substring(0, 7) == "/start=")
                                {
                                    string startTemp = argStr.Substring(7, argStr.Length - 7);
                                    Int32.TryParse(startTemp, out startEvent);
                                    isSetStart = true;
                                }
                            }
                        }

                    }
                }
            }
        }  

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// Execute Method
        /// 

        public void Execute(string[] args)
        {
            ParseArgs(args);

            // Optionally clear tables
            if (isClear && !isStop)
            {
                ClearTables();
                isStop = true;
            }

            if (!isStop)
			{
				// Scan for events and download from web to files
				if (isScan)
				{
					PerformScan();
				}

                // Parse downloaded events files and import
                if (isParse)
                {
                    // Parse downloaded files and load to tmp and stage
                    ParseEvents();
                }
				
                if (isSubmitted)
				{
					ParseSessionSubmissions();
				}

                // Geocode Event Locations and Stage the geocode location data
                if (isGeolocate && !isOffline)
                {
                    try
                    {
                        if (!String.IsNullOrEmpty(bingAPIKey))
                        {
                            GeocodeEvents();
                        }
                        else
                        {
                            Console.WriteLine("   - Bing Maps API Key missing from config file -- cannot geocode events.");
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("   - Error occurred geocoding event locations.  Error: " + ex.ToString());
                    }
                }

                // Load the data from stage to dbo
                LoadAllData();            
			}
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// PerformScan Method
        /// 

        public void PerformScan()
        {
            HttpResponseMessage response = null;
            HttpContent responseContent = null;
            String strPageContent = "";
            string url = "";
            string submittedURL = "";
            string eventNumStr = "";
            string outputFileName = "";
            string submittedOutputFileName = "";
			bool lastWasEmpty = false;
			int numEmptyFiles = 0;
			int i = 0;

			// Get the events to download -- either a full load (all between 1 and ?) or an incremental load based on last value
			if (isFull)
			{
				startEvent = 1;
				numEvents = MAXNUMEVENTS;
				Console.WriteLine("Performing full refresh, starting with Event 1.");
			}
			else
			{
				if (startEvent != 1 || numEvents != MAXNUMEVENTS)
				{
					string numEventStr = "all published";
					if (numEvents != MAXNUMEVENTS)
					{
						numEventStr = numEvents.ToString();
					}
					Console.WriteLine("Performing incremental refresh based on input values.  Starting with Event " + startEvent + " and getting " + numEventStr + " Events.");
				}
				else
				{
                    if (!isSetStart)
                    {
                        startEvent = GetMinEventNumber();
                    }
                    if (!isSetNum)
                    {
                        numEvents = MAXNUMEVENTS;
                    }
					Console.WriteLine("Performing automatic incremental refresh.  Starting with Event " + startEvent + " and getting all published Events.");
				}
			}

            // Perform the page downloads
            if (!isOffline)
            {
                // Not offline, clear cache dir and download the live results
                if (isDelete)
                {
                    RefreshCacheDir();
                }

                Console.WriteLine(String.Format("   - Downloading events from site..."));
				i = startEvent;
				while (i < (startEvent + numEvents) && numEmptyFiles < 20)
                {
                    url = String.Format(BASEURL, i.ToString());
                    string tempStr = "00000" + i.ToString();
                    eventNumStr = tempStr.Substring(tempStr.Length - 5);
                    outputFileName = String.Format(BASEOUTPUTFILENAME, eventNumStr);
                    submittedOutputFileName = String.Format(BASESUBMITTEDOUTPUTFILENAME, eventNumStr);
                    submittedURL = String.Format(BASESUBMITTEDURL, i.ToString());

                    // Download the main XML data page
                    if (!String.IsNullOrEmpty(url))
                    {
                        // Get the page
                        Console.WriteLine("      - Fetching: " + url);
                        try
                        {
                            response = client.GetAsync(url).Result;
                        }
                        catch (Exception ex)
                        {
                            response = new HttpResponseMessage();
                            response.StatusCode = HttpStatusCode.NotFound;
                            Console.WriteLine(String.Format("      - Error accessing event URL ({0}): ", url) + ex.ToString());
                        }

                        // Output the page if received
                        try
                        {
                            responseContent = response.Content;
                            strPageContent = responseContent.ReadAsStringAsync().Result;
                            Thread.Sleep(1000);

                            Console.WriteLine("      - Page downloaded (Status Code: " + response.StatusCode + ")");

							// Write out the downloaded web page to the cache
							if (strPageContent.Length > 100 && strPageContent.IndexOf("<title>404 Error Page</title>") == -1)

                            {
								WriteOutputFile(outputFileName, strPageContent);
							}
							else
							{
								// Increase count of empty files if 2+ empty in a row
								if (lastWasEmpty)
								{
									numEmptyFiles++;
								}
								lastWasEmpty = true;
							}
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine("      - Page not downloaded: " + response.ToString());
                            Console.WriteLine("         - Error Detail: " + ex.ToString());
                        }

                        // Download the submitted HTML page
                        if (!String.IsNullOrEmpty(submittedURL))
                        {
                            // Get the page
                            Console.WriteLine("      - Fetching: " + submittedURL);
                            try
                            {
                                response = client.GetAsync(submittedURL).Result;
                            }
                            catch (Exception ex)
                            {
                                response = new HttpResponseMessage();
                                response.StatusCode = HttpStatusCode.NotFound;
                                Console.WriteLine(String.Format("      - Error accessing event URL ({0}): ", submittedURL) + ex.ToString());
                            }

                            // Output the page if received
                            try
                            {
                                responseContent = response.Content;
                                strPageContent = responseContent.ReadAsStringAsync().Result;
                                Thread.Sleep(1000);

                                Console.WriteLine("      - Page downloaded (Status Code: " + response.StatusCode + ")");

                                // Write out the downloaded web page to the cache
                                if (strPageContent.Length > 0)
                                {
                                    WriteOutputFile(submittedOutputFileName, strPageContent);
                                }
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine("      - Page not downloaded: " + response.ToString());
                                Console.WriteLine("         - Error Detail: " + ex.ToString());
                            }

                        } // Submitted url if

                        // Increment the normal count
                        i++;
					}
                } // while loop
            } // offline
            else
            {
                // Offline, use saved results
                Console.WriteLine(String.Format("   - Offline mode.  Skipping download of events from site."));
            }
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// ParseEvents Method
        /// 

        public void ParseEvents()
        {
            string[] eventFiles = null;
            XmlSerializer eventSerializer = null;
            SQLSaturdayItem eventData = null;
			int eventNum = 0;

			DataTable eventDT = null;
			DataTable sponsorDT = null;
			DataTable speakerDT = null;
			DataTable sessionDT = null;
			DataTable sessionSpeakerDT = null;


			// Read the cache directory files
			eventFiles = GetFileList(cacheDir, "*.xml");

            foreach (string file in eventFiles)
            {
                if (File.Exists(file))
                {
                    try
                    {
						// Schema for Event DataTable
						eventDT = new DataTable();
						eventDT.TableName = DBTABLEEVENT;
						eventDT.Columns.Add("EventNumber", typeof(int));
						eventDT.Columns.Add("EventName", typeof(string));
						eventDT.Columns.Add("NumAttendeeEstimate", typeof(int));
						eventDT.Columns.Add("StartDate", typeof(DateTime));
						eventDT.Columns.Add("TimeZone", typeof(string));
						eventDT.Columns.Add("EventDescription", typeof(string));
						eventDT.Columns.Add("TwitterHashtag", typeof(string));
						eventDT.Columns.Add("VenueName", typeof(string));
						eventDT.Columns.Add("VenueStreet", typeof(string));
						eventDT.Columns.Add("VenueCity", typeof(string));
						eventDT.Columns.Add("VenueState", typeof(string));
						eventDT.Columns.Add("VenueZipCode", typeof(string));

						// Schema for Sponsor DataTable
						sponsorDT = new DataTable();
						sponsorDT.TableName = DBTABLESPONSOR;
						sponsorDT.Columns.Add("EventNumber", typeof(int));
						sponsorDT.Columns.Add("ImportID", typeof(string));
						sponsorDT.Columns.Add("SponsorName", typeof(string));
						sponsorDT.Columns.Add("Label", typeof(string));
						sponsorDT.Columns.Add("SponsorURL", typeof(string));
						sponsorDT.Columns.Add("ImageURL", typeof(string));
						sponsorDT.Columns.Add("ImageHeight", typeof(int));
						sponsorDT.Columns.Add("ImageWidth", typeof(int));

						// Schema for Speaker DataTable
						speakerDT = new DataTable();
						speakerDT.TableName = DBTABLESPEAKER;
						speakerDT.Columns.Add("EventNumber", typeof(int));
						speakerDT.Columns.Add("ImportID", typeof(string));
						speakerDT.Columns.Add("SpeakerName", typeof(string));
						speakerDT.Columns.Add("Label", typeof(string));
						speakerDT.Columns.Add("Description", typeof(string));
						speakerDT.Columns.Add("Twitter", typeof(string));
						speakerDT.Columns.Add("LinkedIn", typeof(string));
						speakerDT.Columns.Add("ContactURL", typeof(string));
						speakerDT.Columns.Add("ImageURL", typeof(string));
						speakerDT.Columns.Add("ImageHeight", typeof(int));
						speakerDT.Columns.Add("ImageWidth", typeof(int));

						// Schema for Session DataTable
						sessionDT = new DataTable();
						sessionDT.TableName = DBTABLESESSION;
						sessionDT.Columns.Add("EventNumber", typeof(int));
						sessionDT.Columns.Add("ImportID", typeof(string));
						sessionDT.Columns.Add("Track", typeof(string));
						sessionDT.Columns.Add("Location", typeof(string));
						sessionDT.Columns.Add("SessionTitle", typeof(string));
						sessionDT.Columns.Add("Description", typeof(string));
						sessionDT.Columns.Add("StartTime", typeof(DateTime));
						sessionDT.Columns.Add("EndTime", typeof(DateTime));

						// Schema for Session Speakers DataTable
						sessionSpeakerDT = new DataTable();
						sessionSpeakerDT.TableName = DBTABLESESSIONSPEAKER;
						sessionSpeakerDT.Columns.Add("EventNumber", typeof(int));
						sessionSpeakerDT.Columns.Add("SessionImportID", typeof(string));
						sessionSpeakerDT.Columns.Add("SessionTitle", typeof(string));
						sessionSpeakerDT.Columns.Add("SpeakerName", typeof(string));

						Console.WriteLine("");
                        Console.WriteLine("   - Parsing event XML file: " + file);

						// Get the event number from the file
						string eventNumStr = Path.GetFileNameWithoutExtension(file);
						int startAt = eventNumStr.IndexOf("_") + 1;
						eventNumStr = eventNumStr.Substring(startAt);

						Int32.TryParse(eventNumStr, out eventNum);
						Console.WriteLine("     SQL Saturday Event # " + eventNum);

						// Deserialize the XML file
						eventSerializer = new XmlSerializer(typeof(SQLSaturdayItem), new XmlRootAttribute("GuidebookXML"));

                        using (Stream reader = new FileStream(file, FileMode.Open))
                        {
                            // Call the Deserialize method to read the file.
                            eventData = (SQLSaturdayItem) eventSerializer.Deserialize(reader);
                        }

						if (eventData != null)
						{
							// Basic guide info
							if (eventData.guide != null)
							{
								string eventName = eventData.guide.name;
								string startDateStr = eventData.guide.startDate;
								DateTime startDate = DateTime.MinValue;
								string attendeeEstimateStr = eventData.guide.attendeeEstimate;
								int attendeeEstimate = 0;
								string timeZoneStr = eventData.guide.timezone;
								string timeZone = "";
								string eventDesc = eventData.guide.description;
								string twitterHashTag = eventData.guide.twitterHashtag;
								string venueName = "";
								string venueStreet = "";
								string venueCity = "";
								string venueState = "";
								string venueZipCode = "";

								// Convert the attendee estimate to int
								Int32.TryParse(attendeeEstimateStr, out attendeeEstimate);

								// Convert the Start Date to a DateTime
								DateTime.TryParse(startDateStr, out startDate);

								// Convert the timezone string to a time zone
								int tzIdx = timeZoneStr.IndexOf(")");

								if (tzIdx > 1)
								{
									timeZoneStr = timeZoneStr.Substring(1, tzIdx - 1);

									if (timeZoneStr == "GMT")
									{
										timeZone = "00:00";
									}
									else
									{
										timeZone = timeZoneStr.Replace("GMT", "");
									}
								}

								if (eventData.guide.venue != null)
								{
									venueName = eventData.guide.venue.name;
									venueStreet = eventData.guide.venue.street;
									venueCity = eventData.guide.venue.city;
									venueState = eventData.guide.venue.state;
									venueZipCode = eventData.guide.venue.zipcode;
								}

								// Populate the Event DataTable
								eventDT.Rows.Add(eventNum, eventName, attendeeEstimate, startDate, timeZone, eventDesc, twitterHashTag, venueName, venueStreet, venueCity, venueState, venueZipCode);
							}

							// Sponsor info
							if (eventData.sponsors != null)
							{
								if (eventData.sponsors.sponsor != null)
								{
									foreach(SQLSaturdayItemSponsor sp in eventData.sponsors.sponsor)
									{
										string importID = sp.importID;
										string name = sp.name;
										string label = sp.label;
										string url = sp.url;
										string imageURL = sp.imageURL;
										string imageHeightStr = sp.imageHeight;
										int imageHeight = 0;
										string imageWidthStr = sp.imageWidth;
										int imageWidth = 0;

										Int32.TryParse(imageHeightStr, out imageHeight);
										Int32.TryParse(imageWidthStr, out imageWidth);

										// Populate the Sponsor DataTable
										sponsorDT.Rows.Add(eventNum, importID, name, label, url, imageURL, imageHeight, imageWidth);
									}
								}
							}

							// Speaker info
							if (eventData.speakers != null)
							{
								if (eventData.speakers.speaker != null)
								{
									foreach(SQLSaturdayItemSpeaker sp in eventData.speakers.speaker)
									{
										string importID = sp.importID;
										string name = sp.name;
										string label = sp.label;
										string description = sp.description;
										string twitter = sp.twitter;
										string linkedin = sp.linkedin;
										string contactURL = sp.ContactURL;
										string imageURL = sp.imageURL;
										string imageHeightStr = sp.imageHeight;
										int imageHeight = 0;
										string imageWidthStr = sp.imageWidth;
										int imageWidth = 0;

										Int32.TryParse(imageHeightStr, out imageHeight);
										Int32.TryParse(imageWidthStr, out imageWidth);

										// Populate the Speaker DataTable
										speakerDT.Rows.Add(eventNum, importID, name, label, description, twitter, linkedin, contactURL, imageURL, imageHeight, imageWidth);
									}
								}		
							}

							// Session (event) info
							if (eventData.sessions != null)
							{
								if (eventData.sessions.session != null)
								{
									foreach (SQLSaturdayItemSession se in eventData.sessions.session)
									{
										string importID = se.importID;
										string track = se.track;
										string locationName = "";
										string title = se.title;
										string description = se.description;
										string startTimeStr = se.startTime;
										DateTime startTime = DateTime.MinValue;
										string endTimeStr = se.endTime;
										DateTime endTime = DateTime.MinValue;

										if (se.location != null)
										{
											locationName = se.location.name;
										}

										// Convert the Start Time to a DateTime
										DateTime.TryParse(startTimeStr, out startTime);

										// Convert the End Time to a DateTime
										DateTime.TryParse(endTimeStr, out endTime);

										// Populate the Speaker DataTable
										sessionDT.Rows.Add(eventNum, importID, track, locationName, title, description, startTime, endTime);

										// Get the speakers for the session
										if (se.speakers != null)
										{
											foreach (SQLSaturdayItemSessionSpeaker s in se.speakers.speaker)
											{
												string speakerID = s.id;
												string speakerName = s.name;

												sessionSpeakerDT.Rows.Add(eventNum, importID, title, speakerName);
											}
										}
									}
								}								
							} // Session (event)


                            // -------------------------------------------------------------------------------------------------------------------------------------------------------- //

                            // Write out the DataTables to SQL database
                            Console.WriteLine("   - Writing parsed data to database");

                            // Events
                            try
                            {
                                WriteDBTable(DBTABLEEVENT, eventDT, true);
                            }
                            catch (Exception e)
                            {
                                Console.WriteLine("   - Unable to load event data to database.  Error:" + e.ToString());
                            }

                            // Sponsors
                            try
                            {
                                WriteDBTable(DBTABLESPONSOR, sponsorDT, true);
                            }
                            catch (Exception e)
                            {
                                Console.WriteLine("   - Unable to load sponsor data to database.  Error:" + e.ToString());
                            }

                            // Speakers
                            try
                            {
                                WriteDBTable(DBTABLESPEAKER, speakerDT, true);
                            }
                            catch (Exception e)
                            {
                                Console.WriteLine("   - Unable to load speaker data to database.  Error:" + e.ToString());
                            }

                            // Sessions
                            try
                            {
                                WriteDBTable(DBTABLESESSION, sessionDT, true);
                            }
                            catch (Exception e)
                            {
                                Console.WriteLine("   - Unable to load session data to database.  Error:" + e.ToString());
                            }

                            // Session Speakers
                            try
                            {
                                WriteDBTable(DBTABLESESSIONSPEAKER, sessionSpeakerDT, true);
                            }
                            catch (Exception e)
                            {
                                Console.WriteLine("   - Unable to load session speaker data to database.  Error:" + e.ToString());
                            }


                            // -------------------------------------------------------------------------------------------------------------------------------------------------------- //

                            // Transform the data from tmp to stage
                            Console.WriteLine("   - Merging data to staging tables...");

                            try
                            {
                                ExecuteSQLProc(DBQUERYSTAGEALL);
                            }
                            catch (Exception e)
                            {
                                Console.WriteLine("   - Unable to merge data to staging tables.  Error:" + e.ToString());
                            }

                            Console.WriteLine("   - Event import complete!");
							Console.WriteLine("");
							Console.WriteLine("---------------------------------------------------------------------------------------------------------");
						} // if eventData
					}
                    catch (Exception e)
                    {
                        Console.WriteLine("      - Error parsing event XML file (" + file + ").  Event detail: " + e.ToString());
                    }
                } // file exists
            } // foreach
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// ParseSessionSubmissions Method
        /// 

        public void ParseSessionSubmissions()
        {
            string[] submittedFiles = null;
            int eventNum = 0;
            int numSubmitted = 0;

            DataTable submittedDT = null;

            // Read the cache directory files
            submittedFiles = GetFileList(cacheDir, "*.html");

            // Schema for Event DataTable
            submittedDT = new DataTable();
            submittedDT.TableName = DBTABLESUBMITTED;
            submittedDT.Columns.Add("EventNumber", typeof(int));
            submittedDT.Columns.Add("SubmittedSessionCount", typeof(int));

            foreach (string file in submittedFiles)
            {
                if (File.Exists(file))
                {
                    try
                    {

                        // Get the event number from the file
                        string eventNumStr = Path.GetFileNameWithoutExtension(file);
                        int startAt = eventNumStr.IndexOf("_") + 1;
                        eventNumStr = eventNumStr.Substring(startAt);

                        Int32.TryParse(eventNumStr, out eventNum);
                        Console.WriteLine("     Getting Submission Count for SQL Saturday Event # " + eventNum);
                      
                        // Do a really dirty parse of the HTML file, this isn't worth loading up the DOM and doing a true search for the one tag we care about
                        int sessionLoc = -1;
                        string readText = File.ReadAllText(file);

                        readText = readText.Replace(" ", "").Replace("\r", "").Replace("\n", "").Replace("\t", "");
                        sessionLoc = readText.IndexOf("SessionsFound:");

                        if (sessionLoc > -1)
                        {
                            if (readText.Length >= sessionLoc + 30)
                            {
                                readText = readText.Substring(sessionLoc, 30);
                                int start = readText.IndexOf(":") + 1;
                                int end = readText.IndexOf("</");
                                if (end > start)
                                {
                                    string numStr = readText.Substring(start, (end - start));
                                    Int32.TryParse(numStr, out numSubmitted);
                                    Console.WriteLine("        " + numSubmitted.ToString() + " sessions");
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine("      - Error parsing submission HTML file (" + file + ").  Event detail: " + e.ToString());
                    }
 
               } //if file exists

                // Populate the Submitted DataTable
                submittedDT.Rows.Add(eventNum, numSubmitted);
            } // foreach

            // Debug output
            /*
            Console.WriteLine("Event:");
            foreach (DataRow row in submittedDT.Rows)
            {
                Console.WriteLine("   Event Number: " + row["EventNumber"]);
                Console.WriteLine("   Submitted Session Count: " + row["SubmittedSessionCount"]);
                Console.WriteLine("");
            }
            */

            // --------------------------------------------------------------------------------------------------------------------------------- //

            // Write out the DataTables to SQL database
            Console.WriteLine("   - Writing parsed data to database");
            try
            {
                WriteDBTable(DBTABLESUBMITTED, submittedDT, true);
            }
            catch (Exception e)
            {
                Console.WriteLine("   - Unable to load submitted count data to database.  Error:" + e.ToString());
            }

            Console.WriteLine("   - Update Session Count and Geocode location data into staging table...");

            // Event data
            Console.WriteLine("      - Updating Submitted Count data");
            try
            {
                ExecuteSQLProc(DBQUERYSTAGESUBMITTED);
            }
            catch (Exception e)
            {
                Console.WriteLine("   - Unable to update event submitted count data.  Error: " + e.ToString());
            }
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// LoadAllData Method
        /// 
        public void LoadAllData()
        {
            // Perform the Load to dbo tables from stage (add surrogate keys)
            Console.WriteLine("   - Loading data from staging to final tables...");

            try
            {
                ExecuteSQLProc(DBQUERYLOADALL);
            }
            catch (Exception e)
            {
                Console.WriteLine("   - Unable to load (merge) data to dbo tables.  Error:" + e.ToString());
            }

        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// RefreshCacheDir Method
        /// 

        public void RefreshCacheDir()
        {
            // Clean out the old cache directory
            if (!isOffline)
            {
                //Console.WriteLine(("   - Removing old cache directory (" + cacheDir + ")");
                try
                {
                    Directory.Delete(cacheDir, true);
                }
                catch (Exception e)
                {
                    string ignore = e.ToString();
                }

                // Quick pause to ensure delete is processed before create
                Thread.Sleep(1000);
            }

            // Create the new cache directory
            try
            {
                Directory.CreateDirectory(cacheDir);
            }
            catch (Exception e)
            {
                Console.WriteLine("   - Could not create cache directory: " + cacheDir + "   :   " + e.ToString());
            }
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// WriteOutputFile Method
        /// 

        public void WriteOutputFile(string fileName, string content)
        {
            StreamWriter outputFile;

            try
            {
                outputFile = new StreamWriter(cacheDir + "\\" + fileName, false);
                {
                    // Remove common illegal characters from XML
                    content = content.Replace("<0", "&lt;0");
                    content = content.Replace("<1", "&lt;1");
                    content = content.Replace("<2", "&lt;2");
                    content = content.Replace("<3", "&lt;3");
                    content = content.Replace("<4", "&lt;4");
                    content = content.Replace("<5", "&lt;5");
                    content = content.Replace("<6", "&lt;6");
                    content = content.Replace("<7", "&lt;7");
                    content = content.Replace("<8", "&lt;8");
                    content = content.Replace("<9", "&lt;9");
                    content = content.Replace("<.", "&lt;.");
                    content = content.Replace("< ", "&lt; ");
                    content = content.Replace("3>", "3&gt;");
                    content = content.Replace("<a ", "&lt;a ");
                    content = content.Replace("\">", "&quot;&gt;");
                    content = content.Replace("</a>", "&lt;/&gt;");
                    content = content.Replace("<>", "!=");
                    content = content.Replace("<br>", "");
                    content = content.Replace("<br />", "");
                    content = content.Replace("<br/>", "");
                    content = content.Replace("<b>", "");
                    content = content.Replace("</b>", "");
                    content = content.Replace("<html><head><title>Object moved</title></head><body>", "");

                    outputFile.AutoFlush = true;
                    outputFile.Write(content);
                    outputFile.Close();
                    //Console.WriteLine("   - Wrote output file: " + fileName);
                }

                outputFile.Dispose();
            }
            catch (Exception e)
            {
                Console.WriteLine("Error creating output file: " + e.ToString());
            }
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// GetFileList Method
        /// 

        public string[] GetFileList(string dir, string mask)
        {
            string[] retList = new string[0];

            if (Directory.Exists(dir))
            {
                try
                {
                    retList = Directory.GetFiles(dir, mask);

                }
                catch (Exception ex)
                {
                    Console.WriteLine("      - Error: Input directory (" + dir + ") not found or unreadable." + ex.ToString());
                }
            }
            else
            {
                Console.WriteLine("      - Error: Input directory (" + dir + ") not found or unreadable.");
            }

            return (retList);
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// GetDBData Method
        /// 

        public DataTable GetDBData(string execSQL)
        {
            DataTable resultTable = new DataTable();

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                try
                {
                    using (SqlCommand command = connection.CreateCommand())
                    {
                        command.CommandText = execSQL;

                        using (SqlDataReader dr = command.ExecuteReader())
                        {
                            resultTable.Load(dr);
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("   Unable to access database data.  Detail: " + ex.ToString());
                    Console.WriteLine("   Query: " + execSQL);
                }

                connection.Close();
            }

            return resultTable;
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// WriteDBTable Method
        /// 
        public void WriteDBTable(string destTableName, DataTable outputTable, bool isTruncate)
        {
            // Write out the DataTables to SQL database
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();

                if (isTruncate)
                {
                    TruncateTable(destTableName);
                }

                //Console.WriteLine("      - Writing data to database (" + destTableName + ")");

                // Write the DataTable to database
                using (SqlBulkCopy bulkCopy = new SqlBulkCopy(connection))
                {
                    foreach (DataColumn c in outputTable.Columns)
                    {
                        //Console.WriteLine("      (Mapping) Table: " + outputTable.TableName + "   Column: " + c.ColumnName);
                        bulkCopy.ColumnMappings.Add(c.ColumnName, c.ColumnName);
                    }

                    bulkCopy.DestinationTableName = outputTable.TableName;
                    try
                    {
                        bulkCopy.WriteToServer(outputTable);
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine("      - Unable to load data to database (" + destTableName + ").  Error:" + e.ToString());
                    }
                }
            }
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// ExecuteSQLProc Method
        ///

        public void ExecuteSQLProc(string sqlProc)
        {
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                try
                {
                    using (SqlCommand command = connection.CreateCommand())
                    {
                        command.CommandText = sqlProc;
                        command.CommandTimeout = 300;
                        command.ExecuteNonQuery();
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine("   - Unable to execute SQL Proc: " + sqlProc + ".  Error: " + e.ToString());
                }

                connection.Close();
            }

            //Console.WriteLine("         - Done!");
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// TruncateTable Method
        /// 

        public void TruncateTable(string sqltable)
        {
            string truncateSQL = String.Format("TRUNCATE TABLE {0}", sqltable);

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                try
                {
                    using (SqlCommand command = connection.CreateCommand())
                    {
                        command.CommandText = truncateSQL;

                        command.ExecuteNonQuery();
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine("   - Unable to truncate temp table: " + sqltable + "  Error:" + e.ToString());
                }

                connection.Close();
            }
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// ClearTables Method
        /// 

        public void ClearTables()
        {
            Console.WriteLine("   - Clearing all database tables...");
            // tmp
            TruncateTable(DBTABLEEVENT);
            TruncateTable(DBTABLESPONSOR);
            TruncateTable(DBTABLESPEAKER);
            TruncateTable(DBTABLESESSION);
            TruncateTable(DBTABLESESSIONSPEAKER);
            TruncateTable(DBTABLESUBMITTED);

            // stage
            TruncateTable(DBTABLEEVENT.Replace("tmp.", "stage."));
            TruncateTable(DBTABLESPONSOR.Replace("tmp.", "stage."));
            TruncateTable(DBTABLESPEAKER.Replace("tmp.", "stage."));
            TruncateTable(DBTABLESESSION.Replace("tmp.", "stage."));

            // dbo
            TruncateTable(DBTABLEEVENT.Replace("tmp.", "dbo."));
            TruncateTable(DBTABLESPONSOR.Replace("tmp.", "dbo."));
            TruncateTable(DBTABLESPEAKER.Replace("tmp.", "dbo."));
            TruncateTable(DBTABLESESSION.Replace("tmp.", "dbo."));

            Console.WriteLine("   - Done!");
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// GetMinEventNumber Method
        /// 

        public int GetMinEventNumber()
        {
            int retVal = 0;

            string execSQL = String.Format(@"
			SELECT
				MIN(EventNumber) AS MinEventNumber
			FROM {0}
			WHERE StartDate >= CONVERT(DATE, DATEADD(DAY, -7, GETDATE())) -- Events that started up to a week ago
				OR StartDate >= CONVERT(DATE, UpdateDateTime) -- Events that are scheduled to start after the last time data was refreshed
			", DBTABLEEVENT.Replace("tmp", "dbo"));

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                try
                {
                    using (SqlCommand command = connection.CreateCommand())
                    {
                        command.CommandText = execSQL;

                        var result = command.ExecuteScalar();
                        Int32.TryParse(result.ToString(), out retVal);
                    }
                }
                catch (Exception e)
                {
                    retVal = 0;
                    e.ToString();
                }

                connection.Close();
            }

            return (retVal);
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// GeocodeEvents Method
        /// 

        public void GeocodeEvents()
        {
            DataTable events = null;
            string sqltable = DBTABLEEVENT.Replace("tmp", "stage");

            string readQuery = @"
				SELECT 
					SQLSaturdayEventID
					,EventNumber
					,VenueStreet
					,VenueCity
					,VenueState
					,VenueZipCode
				FROM stage.SQLSaturdayEvent
				WHERE ISNULL(VenueLatitude, '') = '' OR ISNULL(VenueLongitude, '') = ''
            ";

            readQuery = readQuery.Replace("{0}", sqltable);

            // Read the events in stage
            events = GetDBData(readQuery);

            // For each event, perform a geocoding
            foreach (DataRow row in events.Rows)
            {
                int SQLSaturdayEventID = 0;
                string eventNumber = "";
                string venueStreet = "";
                string venueCity = "";
                string venueState = "";
                string venueZipCode = "";
                string[] geoResults;
                string latitude = "";
                string longitude = "";
                string geoStreet = "";
                string geoCity = "";
                string geoState = "";
                string geoZipCode = "";
                string geoCountry = "";

                string updateSQL = @"
                    UPDATE {0}
	                    SET VenueLatitude = @VenueLatitude
		                    ,VenueLongitude = @VenueLongitude
		                    ,VenueGeoStreet = @VenueGeoStreet
		                    ,VenueGeoCity = @VenueGeoCity
		                    ,VenueGeoState = @VenueGeoState
		                    ,VenueGeoZipCode = @VenueGeoZipCode
		                    ,VenueGeoCountry = @VenueGeoCountry
	                    WHERE SQLSaturdayEventID = {1}
                ";

                if (row["SQLSaturdayEventID"] != null)
                {
                    SQLSaturdayEventID = Convert.ToInt32(row["SQLSaturdayEventID"]);
                }

                if (row["EventNumber"] != null)
                {
                    eventNumber = row["EventNumber"].ToString();
                }

                if (row["VenueStreet"] != null)
                {
                    venueStreet = row["VenueStreet"].ToString();
                }

                if (row["VenueCity"] != null)
                {
                    venueCity = row["VenueCity"].ToString();
                }

                if (row["VenueState"] != null)
                {
                    venueState = row["VenueState"].ToString();
                }

                if (row["VenueZipCode"] != null)
                {
                    venueZipCode = row["VenueZipCode"].ToString();
                }

                try
                {
                    geoResults = GeocodeAddress(eventNumber, venueStreet, venueCity, venueState, venueZipCode);
                    latitude = geoResults[0];
                    longitude = geoResults[1];
                    geoStreet = geoResults[2];
                    geoCity = geoResults[3];
                    geoState = geoResults[4];
                    geoZipCode = geoResults[5];
                    geoCountry = geoResults[6];

                    // Write the updates to the DB
                    updateSQL = String.Format(updateSQL, sqltable, SQLSaturdayEventID);

                    Console.WriteLine("         - Writing geocode result to database.");
                    using (SqlConnection connection = new SqlConnection(connString))
                    {
                        connection.Open();
                        try
                        {
                            using (SqlCommand command = connection.CreateCommand())
                            {
                                command.CommandText = updateSQL;
                                command.Parameters.AddWithValue("@VenueLatitude", latitude);
                                command.Parameters.AddWithValue("@VenueLongitude", longitude);
                                command.Parameters.AddWithValue("@VenueGeoStreet", geoStreet);
                                command.Parameters.AddWithValue("@VenueGeoCity", geoCity);
                                command.Parameters.AddWithValue("@VenueGeoState", geoState);
                                command.Parameters.AddWithValue("@VenueGeoZipCode", geoZipCode);
                                command.Parameters.AddWithValue("@VenueGeoCountry", geoCountry);

                                command.ExecuteNonQuery();
                            }
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine("   - Unable to update event staging table: " + sqltable + ".  ID: " + SQLSaturdayEventID + " Latitude: " + latitude + ", Longitude: " + longitude + ".  Error:" + e.ToString());
                        }

                        connection.Close();
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("   - Unable to geocode address.  Event: " + eventNumber + " Detail: " + ex.ToString());
                }
            }
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// GeocodeAddress Method
        /// 

        public string[] GeocodeAddress(string eventNumber, string street, string city, string state, string zip)
        {
            HttpResponseMessage response = null;
            HttpContent responseContent = null;
            String strPageContent = "";
            BingResult br = null;

            string url = "";

            string geoLatitude = "";
            string geoLongitude = "";
            string geoStreet = "";
            string geoCity = "";
            string geoState = "";
            string geoZip = "";
            string geoCountry = "";
            string[] geoResult = null;

            url = BINGGEOURL;
            // "http://dev.virtualearth.net/REST/v1/Locations?countryRegion={country}&adminDistrict={state}&locality={city}&postalCode={postalCode}&addressLine={addressLine}&key={apikey}";

            url = url.Replace("{apikey}", bingAPIKey);

            url = url.Replace("countryRegion={country}&", "");  // temp disable country

            if (!String.IsNullOrEmpty(street))
            {
                url = url.Replace("{addressLine}", street);
            }
            else
            {
                url = url.Replace("&addressLine={addressLine}", "");
            }

            if (!String.IsNullOrEmpty(city))
            {
                url = url.Replace("{city}", city);
            }
            else
            {
                url = url.Replace("&locality={city}", "");
            }

            if (!String.IsNullOrEmpty(state))
            {
                url = url.Replace("{state}", state);
            }
            else
            {
                url = url.Replace("&adminDistrict={state}", "");
            }

            if (!String.IsNullOrEmpty(zip))
            {
                url = url.Replace("{postalCode}", zip);
            }
            else
            {
                url = url.Replace("&postalCode={postalCode}", "");
            }


            if (!String.IsNullOrEmpty(url))
            {
                // Get the page
                Console.WriteLine("      - Fetching geocode data for event: " + eventNumber);
                //Console.WriteLine("      - Fetching: " + url);
                try
                {
                    response = client.GetAsync(url).Result;
                }
                catch (Exception ex)
                {
                    response = new HttpResponseMessage();
                    response.StatusCode = HttpStatusCode.NotFound;
                    Console.WriteLine(String.Format("      - Error accessing geocoding URL ({0}): ", url) + ex.ToString());
                }

                // Output the page if received
                try
                {
                    responseContent = response.Content;
                    strPageContent = responseContent.ReadAsStringAsync().Result;
                    Thread.Sleep(500);

                    Console.WriteLine("      - Geocode result downloaded (Status Code: " + response.StatusCode + ")");

                    // If we received good data, check and parse it
                    if (strPageContent.Length > 50 && strPageContent.IndexOf("<title>404 Error Page</title>") == -1)
                    {
                        strPageContent = strPageContent.Replace("__type", "type");

                        List<string[]> geoResults = new List<string[]>();
                        int numHighResults = 0;
                        int numMedResults = 0;
                        int numLowResults = 0;

                        // Parse the JSON string into objects
                        JavaScriptSerializer js = new JavaScriptSerializer();
                        br = js.Deserialize<BingResult>(strPageContent);

                        if (br != null)
                        {
                            if (br.resourceSets != null)
                            {
                                foreach (BingResultResourceSet rs in br.resourceSets)
                                {
                                    string confidence = "";
                                    double[] coords;
                                    string longitude = "";
                                    string latitude = "";
                                    string newstreet = "";
                                    string newcity = "";
                                    string newstate = "";
                                    string newzip = "";
                                    string newcountry = "";
                                    string[] coordResult = new string[8];

                                    if (rs.resources != null)
                                    {
                                        foreach (BingResultResourceSetItem rsi in rs.resources)
                                        {
                                            if (rsi.confidence != null)
                                            {
                                                confidence = rsi.confidence;
                                            }

                                            if (rsi.point != null)
                                            {
                                                if (rsi.point.coordinates != null)
                                                {
                                                    coords = rsi.point.coordinates.ToArray();

                                                    if (coords.Length == 2)
                                                    {
                                                        latitude = coords[0].ToString();
                                                        longitude = coords[1].ToString();

                                                        if (rsi.address != null)
                                                        {
                                                            if (rsi.address.addressLine != null)
                                                            {
                                                                newstreet = rsi.address.addressLine;
                                                            }

                                                            if (rsi.address.locality != null)
                                                            {
                                                                newcity = rsi.address.locality;
                                                            }

                                                            if (rsi.address.adminDistrict != null)
                                                            {
                                                                newstate = rsi.address.adminDistrict;
                                                            }

                                                            if (rsi.address.postalCode != null)
                                                            {
                                                                newzip = rsi.address.postalCode;
                                                            }

                                                            if (rsi.address.countryRegion != null)
                                                            {
                                                                newcountry = rsi.address.countryRegion;
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                        } // foreach rsi
                                    }

                                    coordResult[0] = confidence;
                                    coordResult[1] = latitude;
                                    coordResult[2] = longitude;
                                    coordResult[3] = newstreet;
                                    coordResult[4] = newcity;
                                    coordResult[5] = newstate;
                                    coordResult[6] = newzip;
                                    coordResult[7] = newcountry;

                                    if (latitude.Length > 0 && longitude.Length > 0)
                                    {
                                        if (confidence.ToUpper() == "HIGH")
                                        {
                                            numHighResults++;
                                        }

                                        if (confidence.ToUpper() == "MEDIUM")
                                        {
                                            numMedResults++;
                                        }

                                        if (confidence.ToUpper() == "LOW")
                                        {
                                            numLowResults++;
                                        }

                                        geoResults.Add(coordResult);
                                    }
                                } // foreach rs

                                // Get the best result (if multiple)
                                if (numHighResults > 0)
                                {
                                    foreach (string[] result in geoResults)
                                    {
                                        if (result[0].ToUpper() == "HIGH")
                                        {
                                            geoLatitude = result[1];
                                            geoLongitude = result[2];
                                            geoStreet = result[3];
                                            geoCity = result[4];
                                            geoState = result[5];
                                            geoZip = result[6];
                                            geoCountry = result[7];
                                            break;
                                        }
                                    }
                                }
                                else if (numMedResults > 0)
                                {
                                    foreach (string[] result in geoResults)
                                    {
                                        if (result[0].ToUpper() == "MEDIUM")
                                        {
                                            geoLatitude = result[1];
                                            geoLongitude = result[2];
                                            geoStreet = result[3];
                                            geoCity = result[4];
                                            geoState = result[5];
                                            geoZip = result[6];
                                            geoCountry = result[7];
                                            break;
                                        }
                                    }
                                }
                                else if (numLowResults > 0)
                                {
                                    foreach (string[] result in geoResults)
                                    {
                                        if (result[0].ToUpper() == "LOW")
                                        {
                                            geoLatitude = result[1];
                                            geoLongitude = result[2];
                                            geoStreet = result[3];
                                            geoCity = result[4];
                                            geoState = result[5];
                                            geoZip = result[6];
                                            geoCountry = result[7];
                                            break;
                                        }
                                    }
                                }

                                // Output the results
                                geoResult = new string[7];
                                geoResult[0] = geoLatitude;
                                geoResult[1] = geoLongitude;
                                geoResult[2] = geoStreet;
                                geoResult[3] = geoCity;
                                geoResult[4] = geoState;
                                geoResult[5] = geoZip;
                                geoResult[6] = geoCountry;
                            } // if resourceSets
                        } // if br
                    }
                    else
                    {
                        Console.WriteLine("   - Search returned no results.");
                        strPageContent = "";
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("      - Page not downloaded: " + response.ToString());
                    Console.WriteLine("         - Error Detail: " + ex.ToString());
                }
            }

            return geoResult;
        }

        /// ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ///
        ///
        /// Main Method
        ///  

        static void Main(string[] args)
        {
            string dataDir = Directory.GetCurrentDirectory();

            SQLSaturdayData sd = new SQLSaturdayData();

            sd.Execute(args);
        }
    }
}
