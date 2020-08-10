# Miscellaneous EEGLAB functions

- [balance_events](#balance_events) balances events in a dataset
- [count_events](#count_events) counts event type occurrences in a given dataset
- [create_eeglabdataset](#create_eeglabdataset) creates an EEGLAB dataset from a given data matrix
- [get_events_timelocked](#get_events_timelocked) returns the event types around which the current dataset was epoched
- [get_iclabel_components](#get_iclabel_components) returns indices of components classified by ICLabel
- [insert_events_relative](#insert_events_relative) inserts new events before/after specified existing events
- [move_events](#move_events) moves specified events in time, either freely or matching the latency of a following event
- [photo2event](#photo2event) turns photodiode onsets/offsets into event markers
- [plot_erp](#plot_erp) is an alternative function to plot ERPs, with some additional statistics
- [plot_patterns](#plot_patterns) is a topoplot wrapper to plot patterns, optionally resized based on a given weight vector
- [rename_events](#rename_events) gives specified event type(s) a new name
- [study_delete_files](#study_delete_files) is a batch file to delete all files associated with a specified study design


## balance_events
Where events of the same type constitute a single class of events, this script balances these classes (i.e. equalises the number of events per class) by randomly relabelling events from the larger class. Given an EEGLAB dataset and a list of event types, it will return an EEGLAB dataset in which there is an equal number of each of these event types. 

```matlab
>> EEG = balance_events(EEG, {'target', 'nontarget', 'standard'});
relabelled 384 events; left 72 each of 'target', 'nontarget', 'standard'
````


## count_events
Counts the number of all or specified events in an EEGLAB dataset, and returns an array of these numbers plus a cell of the counted types.

```matlab
>> [count, types] = count_events(EEG, {'event1', 'event2'});
98 events of 2 selected types
event1 -    59
event2 -    39
```


## create_eeglabdataset
Creates a dataset in EEGLAB format from given continuous or epoched data, optionally with a specified chanlocs structure, or with specified channel labels. For epochs, the marker type and the epoch start latency can also be indicated.

```matlab
EEG = create_eeglabdataset(randn(3, 512, 100), 512, 'chanlabels', {'C1', 'C2', 'C3'}, 'xmin', -0.2);
```


## get_events_timelocked
Returns a cell array of event types around which the current dataset was epoched. I needed this when working with someone else's epoched data and I didn't know which epochs I was dealing with.


## get_iclabel_components
Returns the indices of components classified by ICLabel, with a certain probability, as being of a certain type. It can select these components by threshold (i.e., all components which have more than x% probability of being a certain type), or by relative majority (i.e., all components which are more probable to be a certain type than any other type). It is additionally possible to exclude components with a residual variance in their dipole model above a certain threshold.

```matlab
>> idx = get_iclabel_components(EEG, 'eye')
idx =
     1
     2
```


## insert_events_relative
Inserts new events a given amount of time in seconds before or after specified existing events. 

```matlab
>> insert_events_relative(EEG, {'event1', 'event2'}, -1.5, 'dummy');
inserted 7 'dummy' events
```


## move_events
Moves specified events, either _forward_ in time to have the same latency as the nearest target event, or simply a specified amount (in ms) forward/backward in time. I use this to fix presentation delays when the markers are set before the actual event happens. I [obtain the real event onsets using a photodiode](https://bci.plus/photosensor), apply [photo2event](#photo2event) to turn photodiode onsets into events, and then move the affected events to these real onset latencies.

```matlab
>> [EEG, diff] = move_events(EEG, 'jump*|grow*', 'photo-onset');
moved 1200 events an average of 130.571 ms

>> EEG = move_events(EEG, '^.*target$', 150);
moved 355 events an average of 150.000 ms
```


## photo2event
Takes an EEGLAB dataset that includes a photodiode channel and transforms the onsets or offsets of this photodiode activity into event markers. When [using a photodiode to obtain real event onset latencies](https://bci.plus/photosensor), this script can turn that photodiode activity into EEGLAB-compatible event markers.

Due to noise, it is advisable to fine-tune the script’s parameters for your use, or at least to evaluate the results. The options are as follows. First of all, the markers can be locked either to the onset (sudden increase) or offset (sudden decrease) of the photo sensor activity. Secondly, a threshold can be set, allowing you to configure at what intensity a sudden change results in a marker being placed. Finally, a refractory period can be set to ignore any above-threshold activity for a certain amount of time after a marker has been set. If the flashes in your paradigm e.g. last 100 ms, a refractory period of, say, a little over 100 ms can make sure no single event generates more than one marker.

It is possible to plot the output of the script for evaluation purposes.

![photo2event plot](./docs/photo2event.png)

The above image shows the first derivative of the photo sensor data in red. The calculated markers are shown and counted in grey. The script’s default threshold at 0.75 appears too high for this recording: a number of onsets are missed. Furthermore, because its onset was missed, it once happened that the offset of a stimulus was erroneously counted as its onset (marker number 4). In this case, we would thus lower the threshold and make sure the refractory period covers the length of the marker presentation.

If it cannot be avoided that erroneous markers are generated, make a note of these markers’ indices in the plot. These indices can then be passed as a final argument to the script, and they will be ignored.

See [STIMULUS SYNCHRONIZATION: Rapid Paradigm Development using SNAP and a Photo Sensor on the BCI+ website](https://bci.plus/photosensor) for more information.


## plot_erp
Plots event-related potentials (ERPs) from any number of given epoched datasets (in EEGLAB format), for a single channel. For each ERP curve, any number of datasets can be given. It can optionally calculate and plot a difference wave, standard errors of the mean, and permutation-based statistics. Mean curves and statistics can be calculated either within or between datasets.

![plot_erp example](https://raw.githubusercontent.com/lrkrol/plot_erp/master/plot_erp-diff.png)

This script can be found on [its own plot_erp GitHub repository](https://github.com/lrkrol/plot_erp).


## plot_patterns
Plots patterns, optionally resizing them based on a given weight vector. By default, the color scale is the same for all patterns, whereas in EEGLAB's default, each pattern has its own scale.

```matlab
plot_patterns(EEG.icawinv(:,1:6), EEG.chanlocs, 'weights', [3 5 6 6 5 3]);
```

![plot_patterns example](./docs/plot_patterns.png)

It uses EEGLAB's `topoplot` and thus also EEGLAB's default colour scheme. The one used in the above image is one of [Kenneth Moreland's diverging colour maps](https://www.kennethmoreland.com/color-maps) generated using [multigradient](https://github.com/lrkrol/multigradient). See [Benedikt Ehinger's blog post on changing EEGLAB's default colour map](https://benediktehinger.de/blog/science/eeglab-gracefully-overwrite-the-default-colormap).


## rename_events

Renames all events of (a) given type(s) to the indicated new type.

```matlab
>> EEG = rename_events(EEG, {'event1a', 'event1b'}, 'event1');
renamed 16 events to 'event1'
```


## study_delete_files
Deletes all files in a given directory (**and all subdirectories**) associated with a specified study design; that is, it gets rid of all those files ending in `.icaerp`, `.icaitc`, `.dattimef` etc.  Definitely **use at your own risk**.