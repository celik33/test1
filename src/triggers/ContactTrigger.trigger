/**
 * Created by salih on 27/11/2024.
 */

trigger ContactTrigger on Contact (after update) {
    ContactTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);

}